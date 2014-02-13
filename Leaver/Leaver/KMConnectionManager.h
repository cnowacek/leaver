//
//  KMConnectionManager.h
//  Leaver
//
//  Created by Charlie Nowacek on 11/7/13.
//  Copyright (c) 2013 KayosMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>
#import <IOBluetoothUI/IOBluetoothUI.h>

NSString *const BluetoothDeviceConnectedNotification = @"BluetoothDeviceConnectedNotification";
NSString *const BluetoothDeviceDisconnectedNotification = @"BluetoothDeviceDisconnectedNotification";
NSString *const BluetoothDeviceConnectionFailedNotification = @"BluetoothDeviceConnectionFailedNotification";
NSString *const BluetoothDeviceQueryReturnedNotification = @"BluetoothDeviceQueryReturnedNotification";

@interface KMConnectionManager : NSObject <IOBluetoothDeviceAsyncCallbacks>

@property (nonatomic, strong)   IOBluetoothDevice *connectedDevice;
@property (nonatomic, strong)   NSTimer *queryTimer;
@property (nonatomic)           BOOL isScreensaverActive;

+ (KMConnectionManager *)sharedManager;

- (void)openConnection;

- (void)disconnect;


@end
