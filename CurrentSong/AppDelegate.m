//
//  AppDelegate.m
//  CurrentSong
//
//  Created by Humberto on 04/13/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "../iTunes.h"

@implementation AppDelegate

// @synthesize window = _window;

- (void)dealloc
{
  [title release];
  [iTunes release];
  [statusItem release];
  [super dealloc];
}

- (IBAction)updateTitle:(id)sender
{
  if( [iTunes isRunning] )
  {
    NSString *songTitle = [[iTunes currentTrack] name];
    if( songTitle != NULL )
    {
      //[statusItem setAttributedTitle:[NSString stringWithString:songTitle]];
      [title beginEditing];
      [title replaceCharactersInRange:NSMakeRange( 0, [title length] ) 
                           withString:songTitle ];
      [title endEditing];
    }
    else
    {
      //[statusItem setAttributedTitle:[NSString stringWithString:@"No Track"]];
      [title beginEditing];
      [title replaceCharactersInRange:NSMakeRange( 0, [title length] ) 
                           withString:@"PY" ];
      [title endEditing];
    }
    [statusItem setAttributedTitle:title];
  }
  else
  {
    [statusItem setAttributedTitle:[NSString stringWithString:@"No iTunes"]];
  }
}

- (void)awakeFromNib
{
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [statusItem retain];
  [statusItem setHighlightMode:NO];
  [statusItem setEnabled:YES];
  [statusItem setToolTip:@"CSongMenulet"];  
  [statusItem setAction:@selector(updateTitle:)];
  [statusItem setTarget:self];

  iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
  [iTunes retain];
  
  NSFont *font = [NSFont fontWithName:@"Geneva" size:10.0];
  NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font 
                                                              forKey:NSFontAttributeName];
  title = [[NSMutableAttributedString alloc] initWithString:@"Hola" 
                                                 attributes:attrsDictionary];
  
  [statusItem setAttributedTitle:title];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // Insert code here to initialize your application
}

@end
