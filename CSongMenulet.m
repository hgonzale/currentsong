//
//  CSongMenulet.m
//  CurrentSong
//
//  Created by Humberto on 04/13/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CSongMenulet.h"

@implementation CSongMenulet

-(void)dealloc
{
    [statusItem release];
    [super dealloc];
}
- (void)awakeFromNib
{
    statusItem = [[[NSStatusBar systemStatusBar] 
                   statusItemWithLength:NSVariableStatusItemLength]
                  retain];
    [statusItem setHighlightMode:YES];
    [statusItem setTitle:[NSString 
                          stringWithString:@"0.0.0.0"]]; 
    [statusItem setEnabled:YES];
    [statusItem setToolTip:@"CSongMenulet"];
    
    [statusItem setAction:@selector(updateIPAddress:)];
    [statusItem setTarget:self];
}

-(IBAction)updateIPAddress:(id)sender
{
  NSString *ipAddr = [NSString stringWithContentsOfURL:
                      [NSURL URLWithString:
                       @"http://highearthorbit.com/service/myip.php"]];
  if(ipAddr != NULL)
    [statusItem setTitle:
     [NSString stringWithString:ipAddr]]; 
}

@end
