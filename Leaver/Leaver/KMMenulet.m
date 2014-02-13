//
//  KMMenulet.m
//  Leaver
//
//  Created by Charlie Nowacek on 10/30/13.
//  Copyright (c) 2013 KayosMedia. All rights reserved.
//

#import "KMMenulet.h"

@interface KMMenulet ()


@property (nonatomic, strong)   IOBluetoothDevice *connectedDevice;
@property (nonatomic)           BOOL isScreensaverActive;
@property (nonatomic)           BOOL isEnteringPassword;

@end

@implementation KMMenulet

- (void)awakeFromNib {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setTitle:@"Scan"];
    [self.statusItem setEnabled:YES];
    [self.statusItem setToolTip:@"IPMenulet"];
    
    [self.statusItem setAction:@selector(startScan)];
    [self.statusItem setTarget:self];
}

- (void)startScan {
    IOBluetoothDeviceSelectorController *selector = [[IOBluetoothDeviceSelectorController alloc] init];
    NSLog(@"Device selector created.");
    int status = [selector runModal];
    
    if (status == kIOBluetoothUISuccess) {
        IOBluetoothDevice *device = [[selector getResults] firstObject];
        NSLog(@"Selection complete! %@", [device name]);
        [device openConnection:self];
    } else {
        NSLog(@"Selection failed!");
    }
}

- (void)connectionComplete:(IOBluetoothDevice *)device status:(IOReturn)status {
    if (status == kIOReturnSuccess) {
        NSLog(@"Device connected!");
        self.connectedDevice = device;
        
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(query) userInfo:nil repeats:YES];
    } else {
        NSLog(@"Something happened :(");
    }
}

- (void)query {
    [self.connectedDevice performSDPQuery:self];
}

- (void)sdpQueryComplete:(IOBluetoothDevice *)device status:(IOReturn)status {
    BluetoothHCIRSSIValue ssi = [device rawRSSI];
    NSLog(@"Strength: %i", ssi);
    if (ssi < -70) {
        NSLog(@"OUT OF RANGE!");
        
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"\r"
                            "set ss to screen saver \"Word of the Day\"\r"
                            "start ss\r"
                            "end tell"];
        
        NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
        NSDictionary *error = nil;
        [script executeAndReturnError:&error];
        if (error) {
            NSLog(@"Error!");
        } else {
            self.isEnteringPassword = NO;
            self.isScreensaverActive = YES;
        }
    }
    
}

- (void)remoteNameRequestComplete:(IOBluetoothDevice *)device status:(IOReturn)status {
    
}

@end
