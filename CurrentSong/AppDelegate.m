//
//  AppDelegate.m
//  CurrentSong
//
//  Created by Humberto on 04/13/2012.
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

#import "AppDelegate.h"
#define ITUNESRUNNINGINTERVAL 5.0
#define ITUNESTOLERANCE 4.0

@implementation AppDelegate

@synthesize menu;
@synthesize aboutWindow;

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

- (void)updateParams:(prefParams *)params
{
  width = params->width;
  updateFreq = params->updateFreq;
  
  [statusItem setLength:width];

  [view setFrame:NSMakeRect( 0.0, 0.0, width, [[NSStatusBar systemStatusBar] thickness] )];
  [view updateParams:params];
}

- (void)showMenu
{
  [statusItem popUpStatusItemMenu:menu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
  [iTunes retain];
  
  preferences = [[prefMgr alloc] initWithOwner:self];
  width = [preferences params]->width;
  updateFreq = [preferences params]->updateFreq;
  
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:width];
  [statusItem retain];
  [statusItem setHighlightMode:NO];
  [statusItem setEnabled:YES];
  
  view = [[myView alloc] initWithFrame:NSMakeRect(0,
                                                  0,
                                                  width,
                                                  [[NSStatusBar systemStatusBar] thickness])
                              andOwner:self
                             andParams:[preferences params]];
  if( ![iTunes isRunning] )
  {
    [view setState:STOPPED]; // Cheap hack to fix hack when we start CurrentSong and iTunes is not running.
                             // This way we enter the case in checkItunesRunning to display the "NOTRUNNING" banner.
  }
  
  [self checkITunesRunning:nil];
  [statusItem setView:view];
  
  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(updateSong:)
                                                          name:@"com.apple.iTunes.playerInfo"
                                                        object:nil];
  
  timerITunesRunning = [NSTimer scheduledTimerWithTimeInterval:ITUNESRUNNINGINTERVAL
                                                        target:self
                                                      selector:@selector(checkITunesRunning:)
                                                      userInfo:nil
                                                       repeats:YES];
  [timerITunesRunning setTolerance:ITUNESTOLERANCE];

  [[NSBundle mainBundle] loadNibNamed:@"aboutWindow" owner:self topLevelObjects:NULL];
  [aboutWindow retain];
  [[NSBundle mainBundle] loadNibNamed:@"statusMenu" owner:self topLevelObjects:NULL];
  [menu retain];
  [menu setDelegate:view];
  
  // Make sure that the windows come to the front when activated.
  [aboutWindow setLevel:NSPopUpMenuWindowLevel];
  [[preferences prefWindow] setLevel:NSPopUpMenuWindowLevel];
}

- (void)quitApp
{
  [[NSUserDefaults standardUserDefaults] synchronize];
  [[NSApplication sharedApplication] terminate:nil];
}

- (void)dealloc
{
  [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
  [preferences release];
  [iTunes release];
  [statusItem release];
  [menu release];
  [aboutWindow release];
  [super dealloc];
}

@end
