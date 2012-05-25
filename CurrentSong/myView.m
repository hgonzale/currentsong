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
#define TOPHEIGHT 10.0
#define BOTTOMHEIGHT 0.0
#define ROTATESEP 25.0
#define BIASINC -1.0
#define SYMBOLCOLOR grayColor
#define STRNOTRUNNING @"iTunes is not running"
#define STRUNKNOWN @"Unknown state"
#define STRNOTRACK @"No Track"

@implementation myView

@synthesize state;

- (id)initWithFrame:(NSRect)frame 
           andOwner:(id <canShowMenu>)myOwner 
          andParams:(prefParams *)params
{
  CGFloat bannerHeight = 0.5 * [[NSStatusBar systemStatusBar] thickness];
  
  self = [super initWithFrame:frame];
  if( !self ) 
  {
    exit(1);
  }
  
  owner = myOwner;

  separator = params->separator;
  [separator retain];
  
  name = nil;
  artist = nil;
  album = nil;
  state = NOTRUNNING;
  
  stop = [NSBezierPath bezierPath];
  [stop appendBezierPathWithRect:NSMakeRect(0, 12.5, 7, 7)];
  [stop setLineWidth:1.0];
  [stop retain];
  
  pause = [NSBezierPath bezierPath];
  [pause appendBezierPathWithRect:NSMakeRect(0, 12.5, 2.5, 7)];
  [pause appendBezierPathWithRect:NSMakeRect(4.5, 12.5, 2.5, 7)];
  [pause setLineWidth:1.0];
  [pause retain];
  
  play = [NSBezierPath bezierPath];
  [play moveToPoint:NSMakePoint(0, 12.5)];
  [play lineToPoint:NSMakePoint(0, 19.5)];
  [play lineToPoint:NSMakePoint(7, 16)];
  [play closePath];
  [play setLineWidth:1.0];
  [play retain];
  
  top = [[rotatingBanner alloc] initWithFrame:NSMakeRect( SYMBOLLENGTH, TOPHEIGHT, [self bounds].size.width - SYMBOLLENGTH, bannerHeight ) 
                                     andOwner:self
                                    andParams:params];
  [top retain];
  
  bottom = [[rotatingBanner alloc] initWithFrame:NSMakeRect( 0.0, BOTTOMHEIGHT, [self bounds].size.width, bannerHeight ) 
                                        andOwner:self
                                       andParams:params];
  [bottom retain];
  
  [self addSubview:top];
  [self addSubview:bottom];
  
  return self;
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
      [top setText:name];

      if( [artist length] == 0 )
        [bottom setText:album];
      else if( [album length] == 0 )
        [bottom setText:artist];
      else
      {
        NSString *temp = [artist stringByAppendingString:separator];
        temp = [temp stringByAppendingString:album];
        [bottom setText:temp];        
      }
      
      break;
      
    case NOTRUNNING:
      [top setText:@""];
      [bottom setText:STRNOTRUNNING];
      break;
      
    default:
      [top setText:@""];
      [bottom setText:STRUNKNOWN];
      break;
  }

  [top startRotating];
  [bottom startRotating];
  
  [self setNeedsDisplay:YES];
}

- (void)didFinishRotating:(id)sender
{
  if(( sender == top && ![bottom isRotating] ) ||
     ( sender == bottom && ![top isRotating] ) )
  {
    [top startRotating];
    [bottom startRotating];
  }
}

- (void)drawRect:(NSRect)dirtyRect
{
  switch( state )
  {
    case PLAYING:
      [[NSColor SYMBOLCOLOR] set];
      [play fill];
      [[NSColor blackColor] set];
      break;

    case PAUSED:
      [[NSColor SYMBOLCOLOR] set];
      [pause fill];
      [[NSColor blackColor] set];
      break;

    case STOPPED:
      [[NSColor SYMBOLCOLOR] set];
      [stop fill];
      [[NSColor blackColor] set];
      break;

    default:
      break;
  }
}

- (void)mouseDown:(NSEvent *)theEvent
{
  [super mouseDown:theEvent];
  [owner showMenu];
}

- (void)updateParams:(prefParams *)params
{
  CGFloat bannerHeight = 0.5 * [[NSStatusBar systemStatusBar] thickness];

  [separator autorelease];
  separator = params->separator;
  [separator retain];
  
  [top setFrame:NSMakeRect( SYMBOLLENGTH, TOPHEIGHT, [self bounds].size.width - SYMBOLLENGTH, bannerHeight )];
  [bottom setFrame:NSMakeRect( 0.0, BOTTOMHEIGHT, [self bounds].size.width, bannerHeight )];
  
  [top updateParams:params];
  [bottom updateParams:params];
}

- (void)dealloc
{
  [play release];
  [pause release];
  [stop release];
  [name release];
  [artist release];
  [album release];
  [separator release];
  [super dealloc];
}

@end
