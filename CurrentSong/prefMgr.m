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
@synthesize rotModeMatrix;

- (id)initWithOwner:(id <hasUpdateParams>)myowner
{
  int dummy;
  
  self = [super init];
  
  owner = myowner;
  
  [NSBundle loadNibNamed:@"prefWindow" owner:self];
  
  NSString *configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:CONFIGFILENAME];
  if( [[NSFileManager defaultManager] fileExistsAtPath:configPath] )
  {
    NSData *data = [NSData dataWithContentsOfFile:configPath];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    params.updateFreq = [unarchiver decodeDoubleForKey:@"updateFreq"];
    if( params.updateFreq == 0.0 ) // Sets default value if not found among params
      params.updateFreq = [updateFreqSlider doubleValue];
    
    params.width = [unarchiver decodeDoubleForKey:@"width"];
    if( params.width == 0.0 ) // Sets default value if not found among params
      params.width = [widthTField doubleValue];      
    
    params.delay = [unarchiver decodeDoubleForKey:@"delay"];
    if( params.delay == 0.0 ) // Sets default value if not found among params
      params.delay = [delayTField doubleValue];
    
    dummy = [unarchiver decodeIntForKey:@"mode"];
    if( dummy == 0 ) // Sets default value if not found among params
      params.mode = [rotModeMatrix selectedRow] + 1;
    else
      params.mode = dummy;
    
    [unarchiver finishDecoding];
    [unarchiver release];    

    [updateFreqSlider setDoubleValue:params.updateFreq];
    [widthTField setDoubleValue:params.width];
    [delayTField setDoubleValue:params.delay];
    [rotModeMatrix selectCellAtRow:(params.mode-1) column:0];
  }
  else
  {
    // NSLog( @"No parameters file found, using defaults." );
    params.updateFreq = [updateFreqSlider doubleValue];
    params.width = [widthTField doubleValue];
    params.delay = [delayTField doubleValue];
    params.mode = [rotModeMatrix selectedRow] + 1;
  }

  return self;
}

- (void)saveParams
{
  NSMutableData *data = [NSMutableData data];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];;
  NSString *configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:CONFIGFILENAME];
  
  [archiver encodeDouble:params.updateFreq forKey:@"updateFreq"];
  [archiver encodeDouble:params.width forKey:@"width"];
  [archiver encodeDouble:params.delay forKey:@"delay"];
  [archiver encodeInt:params.mode forKey:@"mode"];
  [archiver finishEncoding];
  [data writeToFile:configPath atomically:YES];
  [archiver release];
}

- (IBAction)updateParams:(id)sender
{
  params.updateFreq = [updateFreqSlider doubleValue];
  params.width = [widthTField integerValue];
  params.delay = [delayTField doubleValue];
  params.mode = [rotModeMatrix selectedRow] + 1;
  
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
  [super dealloc];
}

@end
