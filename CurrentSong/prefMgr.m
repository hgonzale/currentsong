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
@synthesize updateFreqSlider;
@synthesize widthTField;
@synthesize delayTField;
@synthesize sepStrTField;

- (id)initWithOwner:(id <hasUpdateParams>)myowner
{
  self = [super init];
  
  owner = myowner;
  
  [NSBundle loadNibNamed:@"prefWindow" owner:self];
  
  NSString *configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:CONFIGFILENAME];
  if( [[NSFileManager defaultManager] fileExistsAtPath:configPath] )
  {
    NSData *data = [NSData dataWithContentsOfFile:configPath];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    params.updateFreq = [unarchiver decodeDoubleForKey:@"updateFreq"];
    params.width = [unarchiver decodeDoubleForKey:@"width"];
    params.delay = [unarchiver decodeDoubleForKey:@"delay"];
    params.separator = [unarchiver decodeObjectForKey:@"separator"];
    [params.separator retain];
    [unarchiver finishDecoding];
    [unarchiver release];    

    [updateFreqSlider setDoubleValue:params.updateFreq];
    [widthTField setDoubleValue:params.width];
    [delayTField setDoubleValue:params.delay];
    [sepStrTField setStringValue:params.separator];
  }
  else
  {
    NSLog( @"No parameters file found, using defaults." );
    params.updateFreq = [updateFreqSlider doubleValue];
    params.width = [widthTField doubleValue];
    params.delay = [delayTField doubleValue];
    params.separator = [sepStrTField stringValue];
    [params.separator retain];
  }

  return self;
}

- (IBAction)updateParams:(id)sender
{
  params.updateFreq = [updateFreqSlider doubleValue];
  params.width = [widthTField integerValue];
  params.delay = [delayTField doubleValue];
  [params.separator autorelease];
  params.separator = [sepStrTField stringValue];
  [params.separator retain];

  [owner updateParams:&params];

  // Should rewrite bottomStr here
  
  if( [sender isKindOfClass:[NSButton class]] && [[(NSButton *)sender title] isEqualToString:@"Done" ] )
    [prefWindow performClose:sender];
}

- (prefParams *)params
{
  return &params;
}

- (void)dealloc
{
  [params.separator release];
  [super dealloc];
}

@end
