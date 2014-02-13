//
//  KMAppDelegate.h
//  Leaver
//
//  Created by Charlie Nowacek on 10/29/13.
//  Copyright (c) 2013 KayosMedia. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KMAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (nonatomic, strong)   NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenuItem *connectItem;
@property (weak) IBOutlet NSMenuItem *quitItem;

@end
