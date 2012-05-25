//
//  rotatingBanner.m
//  CurrentSong
//
//  Created by Humberto on 05/23/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "rotatingBanner.h"

#define BIASINC -1.0
#define ROTATESEP 25.0
#define TEXTHEIGHT 0.0

@implementation rotatingBanner

@synthesize mode;
@synthesize isRotating;

- (id)initWithFrame:(NSRect)frame
           andOwner:(id<bannerController>)myowner
          andParams:(prefParams *)params
{
  self = [super initWithFrame:frame];
  if( !self ) 
  {
    exit(1);
  }

  owner = myowner;
  mode = HORIZONTAL_CONT;
  text = nil;
  
  fontAttr = [NSDictionary dictionaryWithObject:[NSFont fontWithName:@"Geneva"
                                                                size:9.0]
                                         forKey:NSFontAttributeName];
  [fontAttr retain];
  
  bias = 0.0;
  length = 0.0;

  isRotating = NO;
  
  [self updateParams:params];
  
  return self;
}

- (void)updateBias:(NSTimer *)sender
{
  CGFloat frameLength = [self bounds].size.width;
  
  switch( mode )
  {
    case HORIZONTAL_CONT:
      if( frameLength < length )
      {
        bias += BIASINC;      
        if( bias + ROTATESEP + length <= 0.0 )
        {
          bias = 0.0;
          isRotating = NO;
          [timer invalidate];
          [owner didFinishRotating:self];
        }
        [self setNeedsDisplay:YES];
      }

      break;
      
    default:
      break;
  }
}

- (void)startRotating
{
  CGFloat frameLength = [self bounds].size.width;
  
  if( frameLength < length && !isRotating )
  {
    [NSTimer scheduledTimerWithTimeInterval:delay
                                     target:self
                                   selector:@selector(finishedDelay:)
                                   userInfo:nil
                                    repeats:NO];
    isRotating = YES;
  }
}

- (void)finishedDelay:(id)sender
{
  timer = [NSTimer scheduledTimerWithTimeInterval:1.0/updateFreq
                                           target:self
                                         selector:@selector(updateBias:)
                                         userInfo:nil
                                          repeats:YES];
}

- (void)setText:(NSString *)myText
{
  [text autorelease];
  text = myText;
  [text retain];
  
  length = [text sizeWithAttributes:fontAttr].width;
  bias = 0.0;
  
  [self setNeedsDisplay:YES];
}

- (void)updateParams:(prefParams *)params
{
  updateFreq = params->updateFreq;
  delay = params->delay;
  
//  if( [timer isValid] )
//  {
//    [timer invalidate];
//    timer = [NSTimer scheduledTimerWithTimeInterval:1.0/updateFreq
//                                             target:self
//                                           selector:@selector(updateBias:)
//                                           userInfo:nil
//                                            repeats:YES];
//  }
}

- (void)drawRect:(NSRect)dirtyRect
{
  CGFloat frameLength = [self bounds].size.width;
  
  switch( mode )
  {
    case HORIZONTAL_CONT:
      [text drawAtPoint:NSMakePoint( bias, TEXTHEIGHT ) 
         withAttributes:fontAttr];
      
      if( frameLength < length && bias + length + ROTATESEP < frameLength )
        [text drawAtPoint:NSMakePoint( bias + length + ROTATESEP, TEXTHEIGHT ) 
           withAttributes:fontAttr];
      
      break;
      
    default:
      break;
  }
}

- (void)dealloc
{
  [text release];
  [fontAttr release];
  [super dealloc];
}

@end
