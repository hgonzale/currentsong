//
//  rotatingBanner.h
//  CurrentSong
//
//  Created by Humberto on 05/23/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "prefMgr.h"

@protocol bannerController
- (void)didFinishRotating:(id)sender;
@end

typedef enum {
  HORIZONTAL_CONT,
  HORIZONTAL_REV,
  VERTICAL
} rotationMode;

@interface rotatingBanner : NSView <hasUpdateParams>
{
  id<bannerController> owner;
  NSString *text;
  CGFloat bias;
  CGFloat length;
  NSDictionary *fontAttr;
  rotationMode mode;
  BOOL isRotating;
  NSTimer *timer;
  
  double updateFreq;
  double delay;
}

- (id)initWithFrame:(NSRect)frame 
           andOwner:(id<bannerController>)myowner 
          andParams:(prefParams *)params;
// - (void)updateBias:(id)sender;
- (void)startRotating;
- (void)updateParams:(prefParams *)params;
- (void)setText:(NSString *)myText;

@property (assign) rotationMode mode;
@property (readonly) BOOL isRotating;

@end
