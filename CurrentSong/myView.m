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

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if( !self ) 
  {
    NSLog( @"Pato Yañez" );
    exit(1);
  }

  [self setName:[NSString stringWithString:@"Name"]];
  [self setArtist:[NSString stringWithString:@"Artist"]];
  [self setAlbum:[NSString stringWithString:@"Album"]];
  [self setFontAttr:[NSDictionary dictionaryWithObject:[NSFont fontWithName:@"Geneva"
                                                                    size:10]
                                             forKey:NSFontAttributeName]];
  
  return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  //[[NSColor selectedMenuItemColor] set];
  //NSRectFill(dirtyRect);

  [name drawAtPoint:NSMakePoint(0,10) withAttributes:fontAttr];
  [artist drawAtPoint:NSMakePoint(0,0) withAttributes:fontAttr];

}

- (void)dealloc
{
  [name release];
  [artist release];
  [album release];
}

@end
