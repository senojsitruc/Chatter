//
//  NSApplication+Additions.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSApplication (Additions)

- (void)systemVersionMajor:(unsigned int *)major minor:(unsigned int *)minor bugFix:(unsigned int *)bugFix;
- (NSString *)systemVersionString;

@end
