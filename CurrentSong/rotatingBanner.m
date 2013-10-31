//
//  rotatingBanner.m
//  CurrentSong
//
//  Created by Humberto on 05/23/2012.
//
//  Copyright (c) 2012, Humberto Gonzalez
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, 
//  are permitted provided that the following conditions are met:
//  - Redistributions of source code must retain the above copyright notice, this list 
//    of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice, this 
//    list of conditions and the following disclaimer in the documentation and/or 
//    other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "rotatingBanner.h"

#define PREFEREDFREQ 12.0 // We choose biasInc and timerPeriod to try to match this number.
#define ROTATESEP 25.0
#define TEXTHEIGHT 0.0
#define FONTNAME @"Helvetica Neue"
#define FONTSIZE 10.0
#define SECONDDELAYTIME 3.0

@implementation rotatingBanner

@synthesize mode;

- (id)initWithFrame:(NSRect)frame
           andOwner:(id <bannerController>)myowner
          andParams:(prefParams *)params
{
  self = [super initWithFrame:frame];
  if( !self ) 
  {
    exit(1);
  }

  owner = myowner;
  mode = HORIZONTAL_CONT;
  state = INACTIVE;
  text = nil;
  bias = 0.0;
  length = 0.0;
  height = 0.0;
  stringReachedEnd = NO;
  
  fontAttr = [NSMutableDictionary dictionaryWithObjectsAndKeys:
              [NSFont fontWithName:FONTNAME size:FONTSIZE],
              //[NSFont menuBarFontOfSize:FONTSIZE],
              NSFontAttributeName,
              [NSColor textColor],
              NSForegroundColorAttributeName,
              nil];
  [fontAttr retain];
    
  [self updateParams:params];
  
  return self;
}

- (void)setText:(NSString *)myText
{
  [text autorelease];
  text = myText;
  [text retain];
  
  length = [text sizeWithAttributes:fontAttr].width;
  height = [text sizeWithAttributes:fontAttr].height;
  bias = 0.0;
  stringReachedEnd = NO;
    
  [self setNeedsDisplay:YES];
  
  [self startDelayAndRotate];
}

- (void)updateParams:(prefParams *)params
{
  CGFloat frameLength = [self bounds].size.width; // The frame was updated by owner.
  
  updateFreq = params->updateFreq;
  delay = params->delay;

  if( [[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)] )
  {
    // Set biasInc to match the granularity of the screen (Retina display, I'm looking at you).
    biasInc = 1.0/[[NSScreen mainScreen] backingScaleFactor];
    // Double biasInc if we are updating too fast.
    if( PREFEREDFREQ < 0.75 * updateFreq ) // Optimal strategy. Math: it works, bitches.
      biasInc *= 2.0;
  }
  else
    biasInc = 1.0;

  timerPeriod = biasInc / updateFreq;
  
  if( mode != params->mode )
  {
    bias = 0.0;
    stringReachedEnd = NO;
  }
  mode = params->mode;
  
  if( frameLength >= length ) // Do nothing, we don't need to rotate.
  {
    state = INACTIVE;
    [rotationTimer invalidate];
    [delayTimer invalidate];

    bias = 0.0;
    stringReachedEnd = NO;
    
    [self setNeedsDisplay:YES];
  }
  
  if( state == ROTATING )
  {
    [rotationTimer invalidate];
    [rotationTimer release];
    rotationTimer = [NSTimer scheduledTimerWithTimeInterval:timerPeriod
                                                     target:self
                                                   selector:@selector(updateBias:)
                                                   userInfo:nil
                                                    repeats:YES];
    [rotationTimer setTolerance:timerPeriod]; // We are pretty tolerant.
    [rotationTimer retain];    
  }
  
  NSLog( @"biasInc = %f, updateFreq = %f, timerPeriod = %f\n", biasInc, updateFreq, timerPeriod );
}

- (void)updateBias:(NSTimer *)sender
{
  CGFloat frameLength = [self bounds].size.width;
  
  // Every now and then a timer keeps running for no apparent reason. This condition kills those timers.
  if( state != ROTATING )
  {
    // NSLog( @"Something weird is going on." );
    [sender invalidate];
    return;
  }
  
  switch( mode )
  {
    case HORIZONTAL_CONT:
      bias -= biasInc;
      [self setNeedsDisplay:YES];

      if( bias + ROTATESEP + length <= 0.0 ) // Exit condition
      {
        bias = 0.0;
        [rotationTimer invalidate];
        state = INACTIVE;
        [owner didFinishRotating:self];
      }
      break;
      
    case HORIZONTAL_REV:
      if( !stringReachedEnd )
      {
        bias -= biasInc;
        [self setNeedsDisplay:YES];
        if( bias + length <= frameLength )
        {
          stringReachedEnd = YES;

          [rotationTimer invalidate];
          state = SECOND_DELAY;
          [delayTimer release];
          delayTimer = [NSTimer scheduledTimerWithTimeInterval:SECONDDELAYTIME
                                                        target:self
                                                      selector:@selector(finishedDelay:)
                                                      userInfo:nil
                                                       repeats:NO];
          [delayTimer setTolerance:5.0*SECONDDELAYTIME];
          [delayTimer retain];
        }
      }
      else
      {
        bias += biasInc;
        [self setNeedsDisplay:YES];
        if( bias >= 0.0 )
        {
          bias = 0.0;
          stringReachedEnd = NO;
          
          [rotationTimer invalidate];
          state = INACTIVE;
          [owner didFinishRotating:self];
        }
      }
      break;
      
    case VERTICAL:
      bias -= biasInc;
      [self setNeedsDisplay:YES];
      
      if( !stringReachedEnd &&
          bias + length <= frameLength )
      {
        bias = 0.0;
        stringReachedEnd = YES;

        [rotationTimer invalidate];
        state = SECOND_DELAY;
        [delayTimer release];
        delayTimer = [NSTimer scheduledTimerWithTimeInterval:SECONDDELAYTIME
                                                      target:self
                                                    selector:@selector(finishedDelay:)
                                                    userInfo:nil
                                                     repeats:NO];
        [delayTimer setTolerance:5.0*SECONDDELAYTIME];
        [delayTimer retain];
      }
      
      if( stringReachedEnd &&
          bias + height <= 0.0 )
      {
        bias = 0.0;
        stringReachedEnd = NO;
        
        [rotationTimer invalidate];
        state = INACTIVE;
        [owner didFinishRotating:self];
      }
      break;

    default:
      break;
  }
}

- (void)startDelayAndRotate
{
  CGFloat frameLength = [self bounds].size.width;

  if( frameLength >= length ) // Do nothing, we don't need to rotate.
  {
    state = INACTIVE;
    return;
  }
  
  switch( state )
  {
    case ROTATING:
      [rotationTimer invalidate];
      // Note the lack of break here.
    case INACTIVE:
      [delayTimer release];
      delayTimer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                    target:self
                                                  selector:@selector(finishedDelay:)
                                                  userInfo:nil
                                                   repeats:NO];
      [delayTimer setTolerance:5.0*delay];
      [delayTimer retain];
      break;
    case DELAY:
    case SECOND_DELAY:
      // Do nothing (for now).
      break;
  }
  
  state = DELAY;
}

- (BOOL)isActive
{
  return ( state != INACTIVE );
}

- (void)finishedDelay:(NSTimer *)sender
{
  // Every now and then a timer keeps running for no apparent reason. This condition kills those timers.
  if( state != DELAY && state != SECOND_DELAY )
  {
    // NSLog( @"Something awful is happening here." );
    [sender invalidate];
    return;
  }
  
  [rotationTimer release];
  rotationTimer = [NSTimer scheduledTimerWithTimeInterval:timerPeriod
                                           target:self
                                         selector:@selector(updateBias:)
                                         userInfo:nil
                                          repeats:YES];
  [rotationTimer setTolerance:timerPeriod];
  [rotationTimer retain];
  
  state = ROTATING;
}

- (void)setIsClicked:(BOOL)isClicked
{
  if( isClicked )
    [fontAttr setValue:[NSColor selectedMenuItemTextColor] forKey:NSForegroundColorAttributeName];
  else
    [fontAttr setValue:[NSColor textColor] forKey:NSForegroundColorAttributeName];
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
      
    case HORIZONTAL_REV:
      [text drawAtPoint:NSMakePoint( bias, TEXTHEIGHT ) 
         withAttributes:fontAttr];
      break;
      
    case VERTICAL:
      if( !stringReachedEnd )
        [text drawAtPoint:NSMakePoint( bias, TEXTHEIGHT ) 
           withAttributes:fontAttr];
      else
      {
        [text drawAtPoint:NSMakePoint( frameLength - length, TEXTHEIGHT - bias ) 
           withAttributes:fontAttr];
        [text drawAtPoint:NSMakePoint( 0.0, TEXTHEIGHT - bias - height ) 
           withAttributes:fontAttr];
      }

    default:
      break;
  }
}

- (void)dealloc
{
  [text release];
  [fontAttr release];
  [rotationTimer release];
  [delayTimer release];
  [super dealloc];
}

@end
