//
//  myView.m
//  CurrentSong
//
//  Created by Humberto on 04/25/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "myView.h"

@implementation myView

@synthesize name;
@synthesize album;
@synthesize artist;
@synthesize fontAttr;
@synthesize state;

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if( !self ) 
  {
    NSLog( @"Pato Yañez" );
    exit(1);
  }

  // [self setName:[NSString stringWithString:@"Name"]];
  // [self setArtist:[NSString stringWithString:@"Artist"]];
  // [self setAlbum:[NSString stringWithString:@"Album"]];
  [self setName:nil];
  [self setArtist:nil];
  [self setAlbum:nil];
  [self setFontAttr:[NSDictionary dictionaryWithObject:[NSFont fontWithName:@"Geneva"
                                                                       size:9]
                                                forKey:NSFontAttributeName]];
  
  stop = [NSBezierPath bezierPathWithRect:NSMakeRect(0, 12.5, 7, 7)];
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
  
  return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  // [[NSColor selectedMenuItemColor] set];
  // NSRectFill(dirtyRect);

  switch(state){
    case STOPPED:
      [stop fill];
      break;
    case PLAYING:
      [play fill];
      break;
    case PAUSED:
      [pause fill];
      break;
    case UNKNOWN:
      NSLog(@"Unknown state, don't know what to do...");
      break;
  }
  [name drawAtPoint:NSMakePoint(12,9) withAttributes:fontAttr];
  [artist drawAtPoint:NSMakePoint(0,-1) withAttributes:fontAttr];
}

- (void)dealloc
{
  [play release];
  [pause release];
  [stop release];
  [name release];
  [artist release];
  [album release];
}

@end
