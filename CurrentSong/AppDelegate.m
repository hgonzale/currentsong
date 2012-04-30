//
//  AppDelegate.m
//  CurrentSong
//
//  Created by Humberto on 04/13/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#define LENGTH 75

@implementation AppDelegate

// @synthesize window = _window;

- (void)dealloc
{
  [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
  // [title release];
  [iTunes release];
  [statusItem release];
  [super dealloc];
}

- (void)updateTitle:(NSNotification *)iTunesNotification
{
  NSString *playerState = nil;
  iTunesState state = UNKNOWN;
  NSDictionary *userInfo = [iTunesNotification userInfo];
  // NSMutableString *title_ = nil;
  
  playerState = [userInfo objectForKey:@"Player State"];
  
  // title_ = [NSMutableString stringWithString:[userInfo objectForKey:@"Name"]];
  // [title_ appendString:@"\n"];
  // [title_ appendString:[userInfo objectForKey:@"Artist"]];
  
  // [title beginEditing];
  // [title replaceCharactersInRange:NSMakeRange( 0, [title length] ) 
  //                      withString:title_];
  // [title endEditing];  

  [view setName:[userInfo objectForKey:@"Name"]];
  [view setArtist:[userInfo objectForKey:@"Artist"]];
  [view setAlbum:[userInfo objectForKey:@"Album"]];
  
  if( [playerState isEqualToString:@"Stopped"] )
  {
    state = STOPPED;
  }
  else if( [playerState isEqualToString:@"Playing"] )
  {
    state = PLAYING;
  }
  else if( [playerState isEqualToString:@"Paused"] )
  {
    state = PAUSED;
  }
  else
  {
    state = UNKNOWN;
  }
  //[statusItem setAttributedTitle:title];
  [view setNeedsDisplay:YES];
}

- (void)awakeFromNib
{
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:LENGTH];
  [statusItem retain];
  [statusItem setHighlightMode:NO];
  [statusItem setEnabled:YES];
  [statusItem setToolTip:@"CSongMenulet"];
  [statusItem setAction:@selector(updateTitle:)];
  [statusItem setTarget:self];
  
  view = [[myView alloc] initWithFrame:NSMakeRect(0,
                                                  0,
                                                  [statusItem length],
                                                  [[NSStatusBar systemStatusBar] thickness])
          ];
  [statusItem setView:view];

  // iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
  // [iTunes retain];
  
  // NSFont *font = [NSFont fontWithName:@"Geneva" size:8.0];
  // NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font 
  //                                                             forKey:NSFontAttributeName];
  // title = [[NSMutableAttributedString alloc] initWithString:@"-" 
  //                                                attributes:attrsDictionary];
  
  // [statusItem setAttributedTitle:title];
  
  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(updateTitle:)
                                                          name:@"com.apple.iTunes.playerInfo"
                                                        object:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // Insert code here to initialize your application
}

@end
