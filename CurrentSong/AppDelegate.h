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

typedef enum {
  PLAYING,
  PAUSED,
  STOPPED,
  UNKNOWN
} iTunesState;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSStatusItem *statusItem;
  iTunesApplication *iTunes;
  myView *view;
  // NSMutableAttributedString *title;
}

// @property (assign) IBOutlet NSWindow *window;

@end
