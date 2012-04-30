//
//  myView.h
//  CurrentSong
//
//  Created by Humberto on 04/25/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface myView : NSView {
  NSString *name;
  NSString *album;
  NSString *artist;
  NSDictionary *fontAttr;
}

@property (retain) NSString *name;
@property (retain) NSString *album;
@property (retain) NSString *artist;
@property (retain) NSDictionary *fontAttr;

@end
