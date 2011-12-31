//
//  MessageOptionsView.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageOptionsView.h"

@implementation MessageOptionsView

/**
 *
 *
 */
- (void)drawRect:(NSRect)rect
{
	CGFloat colors[8] = { 0.894, 0.894, 0.894, 1.0, 0.694, 0.694, 0.694, 1.0 };
	CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
	CGColorSpaceRelease(baseSpace), baseSpace = NULL;
	
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextClearRect(context, NSRectToCGRect(rect));
	CGContextSaveGState(context);
	
	CGPoint endPoint = CGPointMake(CGRectGetMidX(NSRectToCGRect(rect)), CGRectGetMinY(NSRectToCGRect(rect)));
	CGPoint startPoint = CGPointMake(CGRectGetMidX(NSRectToCGRect(rect)), CGRectGetMaxY(NSRectToCGRect(rect)));
	
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	
	CGGradientRelease(gradient), gradient = NULL;
	
	CGContextRestoreGState(context);
	
	[super drawRect:rect];
}

@end
