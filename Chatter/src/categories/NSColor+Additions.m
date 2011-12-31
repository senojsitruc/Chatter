//
//  NSColor+Additions.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSColor+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation NSColor (Additions)

/**
 *
 *
 */
- (CGColorRef)CGColor
{
	NSColor *colorRGB = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	CGFloat components[4];
	
	[colorRGB getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
	
	CGColorSpaceRef theColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGColorRef theColor = CGColorCreate(theColorSpace, components);
	CGColorSpaceRelease(theColorSpace);
	
	return (CGColorRef)[(id)theColor autorelease];
}

/**
 *
 *
 */
+ (NSColor*)colorWithCGColor:(CGColorRef)aColor
{
	const CGFloat *components = CGColorGetComponents(aColor);
	CGFloat red = components[0];
	CGFloat green = components[1];
	CGFloat blue = components[2];
	CGFloat alpha = components[3];
	
	return [self colorWithDeviceRed:red green:green blue:blue alpha:alpha];
}

@end
