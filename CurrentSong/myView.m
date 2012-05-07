//
//  myView.m
//  CurrentSong
//
//  Created by Humberto on 04/25/2012.
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

#import "myView.h"

#define SYMBOLLENGTH 10.0
#define TOPHEIGHT 9.0
#define BOTTOMHEIGHT -1.0
#define ROTATESEP 25.0
#define BIASINC -1
#define SKIPITERS 60
#define SEPARATOR @" – "
#define STRNOTRUNNING @"iTunes not running"
#define STRUNKNOWN @"Unknown state"
#define STRNOTRACK @"No Track"

@implementation myView

@synthesize fontAttr;
@synthesize statusItem;

- (void)menuQuit:(id)sender
{
  [[NSApplication sharedApplication] terminate:nil];
}

- (id)initWithFrame:(NSRect)frame
{
  NSMenuItem *menuItemQuit;
  
  self = [super initWithFrame:frame];
  if( !self ) 
  {
    NSLog( @"super NSView didn't open. Major error." );
    exit(1);
  }
  
  name = nil;
  artist = nil;
  album = nil;
  state = NOTRUNNING;
  [self setFontAttr:[NSDictionary dictionaryWithObject:[NSFont fontWithName:@"Geneva"
                                                                       size:9]
                                                forKey:NSFontAttributeName]];
  
  stop = [NSBezierPath bezierPath];
  [stop appendBezierPathWithRect:NSMakeRect(0, 12.5, 7, 7)];
  [stop setLineJoinStyle:NSRoundLineJoinStyle];
  [stop setLineWidth:1.0];
  [stop retain];
  
  pause = [NSBezierPath bezierPath];
  [pause appendBezierPathWithRect:NSMakeRect(0, 12.5, 2.5, 7)];
  [pause appendBezierPathWithRect:NSMakeRect(4.5, 12.5, 2.5, 7)];
  [pause setLineJoinStyle:NSRoundLineJoinStyle];
  [pause setLineWidth:1.0];
  [pause retain];
  
  play = [NSBezierPath bezierPath];
  [play moveToPoint:NSMakePoint(0, 12.5)];
  [play lineToPoint:NSMakePoint(0, 19.5)];
  [play lineToPoint:NSMakePoint(7, 16)];
  [play closePath];
  [play setLineJoinStyle:NSRoundLineJoinStyle];
  [play setLineWidth:1.0];
  [play retain];
  
  menu = [[NSMenu alloc] init];
  [menu setAutoenablesItems:NO];
  menuItemQuit = [menu addItemWithTitle:@"Quit" action:@selector(menuQuit:) keyEquivalent:@""];
  [menuItemQuit setEnabled:YES];
  [menuItemQuit setTarget:self];
  
  topBias = 0.0;
  bottomBias = 0.0;
  topLength = 0.0;
  bottomLength = 0.0;
  
  topSkipItersCount = 0;
  bottomSkipItersCount = 0;
  
  return self;
}

- (void)updateBias
{
  CGFloat myLength = [self bounds].size.width;
  BOOL needsDisplay = NO;
  
  if( myLength < topLength + SYMBOLLENGTH && topSkipItersCount == 0 )
  {
    topBias = topBias + BIASINC;
    needsDisplay = YES;
  }
  
  if( myLength < bottomLength && bottomSkipItersCount == 0 )
  {
    bottomBias = bottomBias + BIASINC;
    needsDisplay = YES;
  }
  
  if( topBias + ROTATESEP <= -topLength )
  {
    topBias = 0.0;
    topSkipItersCount = SKIPITERS;
  }
  
  if( bottomBias + ROTATESEP <= -bottomLength )
  {
    bottomBias = 0.0;
    bottomSkipItersCount = SKIPITERS;
  }
  
  if( topSkipItersCount > 0 )
    topSkipItersCount--;
  
  if( bottomSkipItersCount > 0 )
    bottomSkipItersCount--;
  
  if( needsDisplay )
    [self setNeedsDisplay:YES];
}

- (void)setName:(NSString *)theName 
      andArtist:(NSString *)theArtist 
       andAlbum:(NSString *)theAlbum 
       andState:(iTunesState)theState
{
  [name autorelease];
  [artist autorelease];
  [album autorelease];

  if( theName == nil || [theName length] == 0 )
    name = [NSString stringWithString:STRNOTRACK];
  else
    name = [theName retain];
  
  if( theArtist == nil )
    artist = [NSString stringWithString:@""];
  else
    artist = [theArtist retain];
  
  if( theAlbum == nil )
    album = [NSString stringWithString:@""];
  else
    album = [theAlbum retain];
  
  state = theState;
  
  switch(state)
  {
    case STOPPED:
    case PLAYING:
    case PAUSED:
      if( [artist length] == 0 )
        bottomStr = album;
      else if( [album length] == 0 )
        bottomStr = artist;
      else
      {
        [bottomStr autorelease];
        bottomStr = [artist stringByAppendingString:SEPARATOR];
        bottomStr = [bottomStr stringByAppendingString:album];
        [bottomStr retain];        
      }
      
      topLength = [name sizeWithAttributes:fontAttr].width;
      topBias = 0.0;
      break;
    case NOTRUNNING:
      bottomStr = [NSString stringWithString:STRNOTRUNNING];

      topLength = 0.0;
      topBias = 0.0;
      break;
    default:
      bottomStr = [NSString stringWithString:STRUNKNOWN];

      topLength = 0.0;
      topBias = 0.0;
  }
  
  bottomLength = [bottomStr sizeWithAttributes:fontAttr].width;
  bottomBias = 0.0;
  
  topSkipItersCount = SKIPITERS;
  bottomSkipItersCount = SKIPITERS;

  [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
  CGFloat myLength = [self bounds].size.width;
  BOOL printStandardBanners = NO;
  
  switch(state)
  {
    case PLAYING:
      [[NSColor grayColor] set];
      [play fill];
      [[NSColor blackColor] set];
      printStandardBanners = YES;
      break;

    case PAUSED:
      [[NSColor grayColor] set];
      [pause fill];
      [[NSColor blackColor] set];
      printStandardBanners = YES;
      break;

    case STOPPED:
      [[NSColor grayColor] set];
      [stop fill];
      [[NSColor blackColor] set];
      printStandardBanners = YES;
      break;

    default:
      [bottomStr drawAtPoint:NSMakePoint(bottomBias,5) 
              withAttributes:fontAttr];
      if( bottomBias + bottomLength < myLength )
        [bottomStr drawAtPoint:NSMakePoint(bottomBias + bottomLength + ROTATESEP,5) 
                withAttributes:fontAttr];
  }

  if( printStandardBanners )
  {
    [name drawAtPoint:NSMakePoint(topBias + SYMBOLLENGTH,TOPHEIGHT) 
       withAttributes:fontAttr];
    if( myLength < topLength + SYMBOLLENGTH && topBias + topLength + ROTATESEP + SYMBOLLENGTH < myLength )
      [name drawAtPoint:NSMakePoint(topBias + topLength + ROTATESEP + SYMBOLLENGTH,TOPHEIGHT) 
         withAttributes:fontAttr];
    
    [bottomStr drawAtPoint:NSMakePoint(bottomBias,BOTTOMHEIGHT) 
            withAttributes:fontAttr];
    if( myLength < bottomLength && bottomBias + bottomLength + ROTATESEP < myLength )
      [bottomStr drawAtPoint:NSMakePoint(bottomBias + bottomLength + ROTATESEP,BOTTOMHEIGHT) 
              withAttributes:fontAttr];
  }
  
  // [[NSColor selectedMenuItemColor] set];
  // NSRectFill(dirtyRect);
}

- (void)mouseDown:(NSEvent *)theEvent
{
  [super mouseDown:theEvent];
  [statusItem popUpStatusItemMenu:menu];
}

- (iTunesState)state
{
  return state;
}

- (void)dealloc
{
  [play release];
  [pause release];
  [stop release];
  [name release];
  [artist release];
  [album release];
  [bottomStr release];
  [menu release];
}

@end
