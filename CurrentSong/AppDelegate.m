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
  [iTunes release];
  [statusItem release];
  [super dealloc];
}

- (void)updateSong:(NSNotification *)iTunesNotification
{
  NSString *playerState = nil;
  NSDictionary *userInfo = [iTunesNotification userInfo];
  
  playerState = [userInfo objectForKey:@"Player State"];
  
  [view setName:[userInfo objectForKey:@"Name"]];
  [view setArtist:[userInfo objectForKey:@"Artist"]];
  [view setAlbum:[userInfo objectForKey:@"Album"]];
  
  if( [playerState isEqualToString:@"Stopped"] )
  {
    [view setState:STOPPED];
  }
  else if( [playerState isEqualToString:@"Playing"] )
  {
    [view setState:PLAYING];
  }
  else if( [playerState isEqualToString:@"Paused"] )
  {
    [view setState:PAUSED];
  }
  else
  {
    [view setState:UNKNOWN];
  }
  [view updateLength];
  [view setNeedsDisplay:YES];
}

- (void)printBanner:(NSTimer *)theTimer
{
  [view updateBias];
  [view setNeedsDisplay:YES];
}

- (void)awakeFromNib
{
  iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
  [iTunes retain];
  
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:LENGTH];
  [statusItem retain];
  [statusItem setHighlightMode:NO];
  [statusItem setEnabled:YES];
  // [statusItem setAction:@selector(updateSong:)];
  [statusItem setTarget:self];
  
  view = [[myView alloc] initWithFrame:NSMakeRect(0,
                                                  0,
                                                  [statusItem length],
                                                  [[NSStatusBar systemStatusBar] thickness])];

  if( [iTunes isRunning] )
  {
    [view setName:[[iTunes currentTrack] name]];
    [view setArtist:[[iTunes currentTrack] artist]];
    [view setAlbum:[[iTunes currentTrack] album]];
    switch([iTunes playerState])
    {
      case iTunesEPlSPlaying:
        [view setState:PLAYING];
        break;
      case iTunesEPlSPaused:
        [view setState:PAUSED];
        break;
      case iTunesEPlSStopped:
        [view setState:STOPPED];
        break;
      default:
        // either FastForwarding or Rewinding
        [view setState:UNKNOWN];
    }
  }
  else
  {
    [view setState:NOTRUNNING];
  }
  [statusItem setView:view];
    
  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(updateSong:)
                                                          name:@"com.apple.iTunes.playerInfo"
                                                        object:nil];

  timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                           target:self
                                         selector:@selector(printBanner:)
                                         userInfo:nil
                                          repeats:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // Insert code here to initialize your application
}

@end
