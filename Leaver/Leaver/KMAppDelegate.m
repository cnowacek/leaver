//
//  KMAppDelegate.m
//  Leaver
//
//  Created by Charlie Nowacek on 10/29/13.
//  Copyright (c) 2013 KayosMedia. All rights reserved.
//

#import "KMAppDelegate.h"
#import "KMConnectionManager.h"
#import <Foundation/NSDistributedNotificationCenter.h>

@interface KMAppDelegate ()

@property (weak) IBOutlet NSMenuItem *infoMenuItem;
@property (nonatomic, strong)   NSLevelIndicator *levelIndicator;

@end

@implementation KMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Finished Launching!");

}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[KMConnectionManager sharedManager] disconnect];
}

-(void)awakeFromNib{
    self.levelIndicator = [[NSLevelIndicator alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 200, 40))];
    
    self.levelIndicator.minValue = 0;
    self.levelIndicator.maxValue = 10;
    self.levelIndicator.criticalValue = 8;
    self.levelIndicator.warningValue = 6;
    
    [self.levelIndicator setTarget:self];
    [self.levelIndicator setAction:@selector(indicatorTapped:)];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.view = self.levelIndicator;
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"Not Connected"];
    [self.statusItem setHighlightMode:YES];
    
    self.infoMenuItem.title = @"SSI: --";
}

- (void)indicatorTapped:(id)sender {
    [self.statusItem popUpStatusItemMenu:self.statusMenu];
    return;
}

- (IBAction)connect:(id)sender {
    if ([KMConnectionManager sharedManager].connectedDevice) {
        [[KMConnectionManager sharedManager] disconnect];
    } else {
        self.statusItem.title = @"Connecting...";
        [[KMConnectionManager sharedManager] openConnection];
    }
}

- (IBAction)quit:(id)sender {
    [NSApp terminate:self];
}

- (void)connectionOpened {
    [self.statusItem setTitle:@"Connected!"];
    [self.connectItem setTitle:@"Disconnect"];
}

- (void)connectionFailed {
    self.statusItem.title = @"Connection Failed!";
}

- (void)disconnected {
    // Reset our menu
    [self.connectItem setTitle:@"Connect"];
    self.infoMenuItem.title = @"SSI: --";
    self.statusItem.title = @"Not connected";
}

- (void)connectionLost {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Connection lost"];
    [alert setInformativeText:@"We lost connection with your device. As a precaution we put your computer to sleep anyways. Please reconnect your device."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
}

- (void)queryReturned {
    IOBluetoothDevice *device = [KMConnectionManager sharedManager].connectedDevice;
    BluetoothHCIRSSIValue ssi = [device rawRSSI];
    self.infoMenuItem.title = [NSString stringWithFormat:@"SSI: %idB", ssi];
    self.statusItem.title = [NSString stringWithFormat:@"Connected! %idB", ssi];
    
    self.levelIndicator.integerValue = abs(ssi)/10;
}



@end
