//
//  myView.m
//  CurrentSong
//
//  Created by Humberto on 04/25/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "myView.h"

#define BOTTOMSEP 6.0
#define TOPHEIGHT 9.0
#define BOTTOMHEIGHT -1.0
#define BIASINC -1.0

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
  
  topBias = 0.0;
  bottomBias = 0.0;
  topLength = 0.0;
  bottomLength = 0.0;
  
  return self;
}

- (void)updateLength
{
  switch(state)
  {
    case STOPPED:
    case PLAYING:
    case PAUSED:
      topLength = 12 + [name sizeWithAttributes:fontAttr].width; // Magic number!
      break;
    default:
      topLength = [name sizeWithAttributes:fontAttr].width;
  }
  bottomLength = [album sizeWithAttributes:fontAttr].width + [artist sizeWithAttributes:fontAttr].width + BOTTOMSEP;
}

- (void)updateBias
{
  topBias = topBias + BIASINC;
  bottomBias = bottomBias + BIASINC;
}

- (void)drawRect:(NSRect)dirtyRect
{
  CGFloat artistLen;

  artistLen = [artist sizeWithAttributes:fontAttr].width + BOTTOMSEP;
  
  switch(state)
  {
    case STOPPED:
      [stop fill];
      [name drawAtPoint:NSMakePoint(12,TOPHEIGHT) withAttributes:fontAttr];
      [artist drawAtPoint:NSMakePoint(0,BOTTOMHEIGHT) withAttributes:fontAttr];
      [album drawAtPoint:NSMakePoint(artistLen,BOTTOMHEIGHT) withAttributes:fontAttr];
      break;
    case PLAYING:
      [play fill];
      [name drawAtPoint:NSMakePoint(12,TOPHEIGHT) withAttributes:fontAttr];
      [artist drawAtPoint:NSMakePoint(0,BOTTOMHEIGHT) withAttributes:fontAttr];
      [album drawAtPoint:NSMakePoint(artistLen,BOTTOMHEIGHT) withAttributes:fontAttr];
      break;
    case PAUSED:
      [pause fill];
      [name drawAtPoint:NSMakePoint(12,TOPHEIGHT) withAttributes:fontAttr];
      [artist drawAtPoint:NSMakePoint(0,BOTTOMHEIGHT) withAttributes:fontAttr];
      [album drawAtPoint:NSMakePoint(artistLen,BOTTOMHEIGHT) withAttributes:fontAttr];
      break;
    case NOTRUNNING:
      [[NSString stringWithString:@"iTunes not running"] drawAtPoint:NSMakePoint(0,5) withAttributes:fontAttr];
      break;
    default:
      [[NSString stringWithString:@"Unknown state..."] drawAtPoint:NSMakePoint(0,5) withAttributes:fontAttr];
  }
  
  // [[NSColor selectedMenuItemColor] set];
  // NSRectFill(dirtyRect);
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
