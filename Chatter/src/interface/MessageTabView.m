//
//  MessageTabView.m
//  Chatter
//
//  Created by Jones Curtis on 2011.07.18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageTabView.h"

@implementation MessageTabView

@dynamic isSelected;
@synthesize handler = mHandler;

/**
 *
 *
 */
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	
	if (self) {
		//[mLabel removeFromSuperview];
	}
	
	return self;
}

- (void)awakeFromNib
{
	[mLabel retain];
}

/**
 *
 *
 */
- (void)drawRect:(NSRect)dirtyRect
{
	NSRect rect = NSMakeRect(0., 0., self.frame.size.width, self.frame.size.height);
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGColorRef fillColor, lineColor = CGColorCreate(colorSpace, (CGFloat[]){0., 0., 0., 1.});
	CGContextClearRect(context, NSRectToCGRect(dirtyRect));
	CGContextSaveGState(context);
	
	if (mIsSelected) {
		mLabel.textColor = [NSColor whiteColor];
		fillColor = CGColorCreate(colorSpace, (CGFloat[]){0xA1/256., 0xA1/256., 0xA1/256., 1.0});
		
		CGContextSetLineWidth(context, 1.);
		CGContextSetFillColorWithColor(context, fillColor);
		CGContextSetStrokeColorWithColor(context, lineColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
		CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
		CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
		CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathFillStroke);
	}
	else {
		mLabel.textColor = [NSColor blackColor];
		fillColor = CGColorCreate(colorSpace, (CGFloat[]){0xA1/256., 0xA1/256., 0xA1/256., 1.0});
		
		rect = dirtyRect;
		
		CGFloat colors[8] = { 0.894, 0.894, 0.894, 1.0, 0.694, 0.694, 0.694, 1.0 };
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
		CGPoint endPoint = CGPointMake(CGRectGetMidX(NSRectToCGRect(rect)), CGRectGetMinY(NSRectToCGRect(rect)));
		CGPoint startPoint = CGPointMake(CGRectGetMidX(NSRectToCGRect(rect)), CGRectGetMaxY(NSRectToCGRect(rect)));
		CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
		CGGradientRelease(gradient), gradient = NULL;
		
		rect = NSMakeRect(0., 0., self.frame.size.width, self.frame.size.height);
		
		CGContextSetLineWidth(context, 1.);
		CGContextSetFillColorWithColor(context, fillColor);
		CGContextSetStrokeColorWithColor(context, lineColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
		CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
		CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
		CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathStroke);
	}
	
	/*
	if (mIsSelected) {
		mLabel.textColor = [NSColor whiteColor];
		fillColor = CGColorCreate(colorSpace, (CGFloat[]){0x3B/256., 0x3B/256., 0x3B/256., 1.0});
	}
	else {
		mLabel.textColor = [NSColor blackColor];
		fillColor = CGColorCreate(colorSpace, (CGFloat[]){0xA1/256., 0xA1/256., 0xA1/256., 1.0});
	}
	
	CGContextSetFillColorWithColor(context, fillColor);
	CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
	CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathFillStroke);
	*/
	
	CGColorSpaceRelease(colorSpace);
	CGContextRestoreGState(context);
	
	[mLabel removeFromSuperview];
	[mLabel setFrameOrigin:NSMakePoint((NSWidth([self bounds]) - NSWidth([mLabel frame])) / 2, (NSHeight([self bounds]) - NSHeight([mLabel frame]) - 2.) / 2)];
	[mLabel setBoundsOrigin:NSMakePoint((NSWidth([self bounds]) - NSWidth([mLabel frame])) / 2, (NSHeight([self bounds]) - NSHeight([mLabel frame]) - 2.) / 2)];
	[mLabel drawRect:dirtyRect];
	
	[super drawRect:dirtyRect];
}

/**
 *
 *
 */
- (void)mouseDown:(NSEvent *)theEvent
{
	if (mHandler != NULL)
		mHandler(self);
}

/**
 *
 *
 */
- (BOOL)isSelected
{
	return mIsSelected;
}

/**
 *
 *
 */
- (void)setIsSelected:(BOOL)aBool
{
	mIsSelected = aBool;
	[self setNeedsDisplay:TRUE];
}

@end
