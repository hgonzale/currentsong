//
//  AppDelegate.m
//  CurrentSong
//
//  Created by Humberto on 04/13/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#define LENGTH 75
#define BANNERUPDATEINTERVAL 1.0/10.0
#define ITUNESRUNNINGINTERVAL 2.0

@implementation AppDelegate

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
  iTunesState myState;
  NSDictionary *userInfo = [iTunesNotification userInfo];
  
  playerState = [userInfo objectForKey:@"Player State"];
  if( [playerState isEqualToString:@"Stopped"] )
    myState = STOPPED;
  else if( [playerState isEqualToString:@"Playing"] )
    myState = PLAYING;
  else if( [playerState isEqualToString:@"Paused"] )
    myState = PAUSED;
  else
    myState = UNKNOWN;

  [view setName:[userInfo objectForKey:@"Name"]
      andArtist:[userInfo objectForKey:@"Artist"]
       andAlbum:[userInfo objectForKey:@"Album"]
       andState:myState];
}

- (void)printBanner:(NSTimer *)theTimer
{
  [view updateBias];
}

- (void)checkITunesRunning:(NSTimer *)theTimer
{
  iTunesState myState;

  if( [view state] != NOTRUNNING && ![iTunes isRunning] )
    [view setName:nil andArtist:nil andAlbum:nil andState:NOTRUNNING];
  else if( [view state] == NOTRUNNING && [iTunes isRunning] )
  {
    switch( [iTunes playerState] )
    {
      case iTunesEPlSPlaying:
        myState = PLAYING;
        break;
      case iTunesEPlSPaused:
        myState = PAUSED;
        break;
      case iTunesEPlSStopped:
        myState = STOPPED;
        break;
      default:
        // either FastForwarding or Rewinding
        myState = UNKNOWN;
    }
    [view setName:[[iTunes currentTrack] name]
        andArtist:[[iTunes currentTrack] artist]
         andAlbum:[[iTunes currentTrack] album]
         andState:myState];
  }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
  [iTunes retain];
  
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:LENGTH];
  [statusItem retain];
  [statusItem setHighlightMode:NO];
  [statusItem setEnabled:YES];
  
  view = [[myView alloc] initWithFrame:NSMakeRect(0,
                                                  0,
                                                  [statusItem length],
                                                  [[NSStatusBar systemStatusBar] thickness])];
  
  [self checkITunesRunning:nil];
  [view setStatusItem:statusItem];
  [statusItem setView:view];
  
  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(updateSong:)
                                                          name:@"com.apple.iTunes.playerInfo"
                                                        object:nil];
  
  timerBannerUpdate = [NSTimer scheduledTimerWithTimeInterval:BANNERUPDATEINTERVAL
                                                       target:self
                                                     selector:@selector(printBanner:)
                                                     userInfo:nil
                                                      repeats:YES];
  
  timerITunesRunning = [NSTimer scheduledTimerWithTimeInterval:ITUNESRUNNINGINTERVAL
                                                        target:self
                                                      selector:@selector(checkITunesRunning:)
                                                      userInfo:nil
                                                       repeats:YES];
}

@end
