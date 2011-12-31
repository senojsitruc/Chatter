//
//  StatusbarView.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatusbarView.h"

@implementation StatusbarView

/**
 *
 *
 */
- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
		[mStatusTxt setStringValue:@""];
		[mProgressTxt setStringValue:@""];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doHandleStatusTextChangedNotification:) name:@"ChatterNotificationStatusTextChanged" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doHandleProgressTextChangedNotification:) name:@"ChatterNotificationProgressTextChanged" object:nil];
	}
	
	return self;
}

/**
 *
 *
 */
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

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

/**
 * ChatterNotificationStatusTextChanged
 *
 */
- (void)doHandleStatusTextChangedNotification:(NSNotification *)notification
{
	[mStatusTxt setStringValue:[notification object]];
}

/**
 * ChatterNotificationProgressTextChanged
 *
 */
- (void)doHandleProgressTextChangedNotification:(NSNotification *)notification
{
	NSString *progressTxt = [notification object];
	
	if ([progressTxt length] == 0)
		[mProgressPrg stopAnimation:self];
	else
		[mProgressPrg startAnimation:self];
	
	[mProgressTxt setStringValue:progressTxt];
}

@end
