//
//  AppDelegate.h
//  CurrentSong
//
//  Created by Humberto on 04/13/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "../iTunes.h"
#import "myView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSStatusItem *statusItem;
  iTunesApplication *iTunes;
  myView *view;
}

// @property (assign) IBOutlet NSWindow *window;

@end
