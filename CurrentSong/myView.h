//
//  myView.h
//  CurrentSong
//
//  Created by Humberto on 04/25/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
  PLAYING,
  PAUSED,
  STOPPED,
  NOTRUNNING,
  UNKNOWN
} iTunesState;

@interface myView : NSView {
  NSDictionary *fontAttr;
  NSStatusItem *statusItem;
  
@private
  NSString *name;
  NSString *album;
  NSString *artist;
  NSString *bottomStr;

  iTunesState state;
  
  int topSkipItersCount;
  int bottomSkipItersCount;
  
  NSBezierPath *stop;
  NSBezierPath *play;
  NSBezierPath *pause;

  NSMenu *menu;
  
  CGFloat topBias;
  CGFloat bottomBias;
  CGFloat topLength;
  CGFloat bottomLength;
}

@property (retain) NSStatusItem *statusItem;
@property (retain) NSDictionary *fontAttr;

- (void)updateBias;
- (void)setName:(NSString *)theName 
      andArtist:(NSString *)theArtist 
       andAlbum:(NSString *)theAlbum 
       andState:(iTunesState)theState;
- (iTunesState)state;

@end
