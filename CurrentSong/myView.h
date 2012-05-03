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
  NSString *name;
  NSString *album;
  NSString *artist;
  NSDictionary *fontAttr;
  iTunesState state;

@private
  NSBezierPath *stop;
  NSBezierPath *play;
  NSBezierPath *pause;
  CGFloat topBias;
  CGFloat bottomBias;
  CGFloat topLength;
  CGFloat bottomLength;
}

@property (retain) NSString *name;
@property (retain) NSString *album;
@property (retain) NSString *artist;
@property (retain) NSDictionary *fontAttr;
@property iTunesState state;

- (void)updateBias;
- (void)updateLength;

@end
