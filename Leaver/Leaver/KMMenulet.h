//
//  KMMenulet.h
//  Leaver
//
//  Created by Charlie Nowacek on 10/30/13.
//  Copyright (c) 2013 KayosMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>
#import <IOBluetoothUI/IOBluetoothUI.h>

@interface KMMenulet : NSObject <IOBluetoothDeviceAsyncCallbacks>

@property (nonatomic, strong)   NSStatusItem *statusItem;

@end
