//
//  KMConnectionManager.m
//  Leaver
//
//  Created by Charlie Nowacek on 11/7/13.
//  Copyright (c) 2013 KayosMedia. All rights reserved.
//

#import "KMConnectionManager.h"

@implementation KMConnectionManager

- (id)init {
    self = [super init];
    
    if (self) {
        NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
        
        [center addObserver:self
                   selector:@selector(wake:)
                       name:@"com.apple.screensaver.didstop"
                     object:nil];
        
        [center addObserver:self
                   selector:@selector(sleep:)
                       name:@"com.apple.screensaver.didstart"
                     object:nil];
    }
    return self;
}

- (void)dealloc {
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)sleep:(NSNotification *)notification {
    NSLog(@"SLEEP!");
    self.isScreensaverActive = YES;
}

- (void)wake:(NSNotification *)notification {
    NSLog(@"WAKE!");
    self.isScreensaverActive = NO;
}

- (void)openConnection {
    IOBluetoothDeviceSelectorController *selector = [[IOBluetoothDeviceSelectorController alloc] init];
    int status = [selector runModal];
    
    if (status == kIOBluetoothUISuccess) {
        IOBluetoothDevice *device = [[selector getResults] firstObject];
        [device openConnection:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothDeviceConnectedNotification object:nil];
    } else {
        NSLog(@"Selection failed!");
        [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothDeviceConnectionFailedNotification object:nil];
        [self disconnect];
    }
    
}

- (void)disconnect {
    // Invalidate the timer to stop querying
    [self.queryTimer invalidate];
    self.queryTimer = nil;
    
    // Close the connection
    [self.connectedDevice closeConnection];
    self.connectedDevice = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothDeviceDisconnectedNotification object:nil];
}

- (void)connectionComplete:(IOBluetoothDevice *)device status:(IOReturn)status {
    if (status == kIOReturnSuccess) {
        self.connectedDevice = device;
        self.queryTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(query) userInfo:nil repeats:YES];
    } else {
        NSLog(@"Something happened :(");
    }
}

- (void)query {
    [self.connectedDevice performSDPQuery:self];
}

#pragma mark - Async Query Methods

- (void)sdpQueryComplete:(IOBluetoothDevice *)device status:(IOReturn)status {
    if (!self.connectedDevice) {
        return;
    }
    
    self.connectedDevice = device;
    BluetoothHCIRSSIValue ssi = [device rawRSSI];
    
    if ((ssi < -70) && !self.isScreensaverActive) {
        [self activateScreenSaver];
    } else if (ssi > 0) {
        
        [self disconnect];
        [self activateScreenSaver];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothDeviceQueryReturnedNotification object:nil];
    
}

- (void)activateScreenSaver {
    NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"\r"
                        "set ss to screen saver \"Word of the Day\"\r"
                        "start ss\r"
                        "end tell"];
    
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    NSDictionary *error = nil;
    [script executeAndReturnError:&error];
    if (error) {
        NSLog(@"Error!");
    }
    
}

- (void)remoteNameRequestComplete:(IOBluetoothDevice *)device status:(IOReturn)status {
    
}

@end
