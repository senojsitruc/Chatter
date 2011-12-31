//
//  NSColor+Additions.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSColor (Additions)

@property (readonly) CGColorRef CGColor;

+ (NSColor *)colorWithCGColor:(CGColorRef)aColor;

@end
