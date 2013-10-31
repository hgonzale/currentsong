//
//  prefMgr.m
//  CurrentSong
//
//  Created by Humberto on 05/20/2012.
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

#import "prefMgr.h"

@implementation prefMgr

@synthesize prefWindow;

- (id)initWithOwner:(id <hasUpdateParams>)myowner
{
  self = [super init];
  
  owner = myowner;
  
  [[NSBundle mainBundle] loadNibNamed:@"prefWindow" owner:self topLevelObjects:NULL];
  [prefWindow retain];

  NSDictionary *defaultParams = [NSDictionary dictionaryWithContentsOfFile:
                                 [[NSBundle mainBundle] pathForResource:@"defaultParams"
                                                                 ofType:@"plist"]];
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaultParams];
  [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultParams];
  
  params.updateFreq = [[NSUserDefaults standardUserDefaults] floatForKey:@"updateFreq"];
  params.width = [[NSUserDefaults standardUserDefaults] floatForKey:@"width"];
  params.delay = [[NSUserDefaults standardUserDefaults] floatForKey:@"delay"];
  params.mode = (rotationMode)[[NSUserDefaults standardUserDefaults] integerForKey:@"rotMode"];

  return self;
}

- (IBAction)updateParams:(id)sender
{
  params.updateFreq = [[NSUserDefaults standardUserDefaults] floatForKey:@"updateFreq"];
  params.width = [[NSUserDefaults standardUserDefaults] floatForKey:@"width"];
  params.delay = [[NSUserDefaults standardUserDefaults] floatForKey:@"delay"];
  params.mode = (rotationMode)[[NSUserDefaults standardUserDefaults] integerForKey:@"rotMode"];
  
  [owner updateParams:&params];

  if( [sender isKindOfClass:[NSButton class]] && [[(NSButton *)sender title] isEqualToString:@"Done" ] )
    [prefWindow performClose:sender];
}

- (prefParams *)params
{
  return &params;
}

- (void)dealloc
{
  [prefWindow release];
  [super dealloc];
}

@end
