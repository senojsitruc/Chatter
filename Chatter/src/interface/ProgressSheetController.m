//
//  ProgressSheetController.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProgressSheetController.h"

@implementation ProgressSheetController

@synthesize window = mWindow;
@synthesize titleTxt = mTitleTxt;
@synthesize progress = mProgress;
@synthesize subtitleTxt = mSubtitleTxt;





#pragma mark - Structors

/**
 *
 *
 */
- (void)dealloc
{
	self.window = nil;
	self.titleTxt = nil;
	self.progress = nil;
	self.subtitleTxt = nil;
	
	[super dealloc];
}

/**
 *
 *
 */
- (void)awakeFromNib
{
	mIsIndeterminate = TRUE;
	[mProgress setIndeterminate:TRUE];
}





#pragma mark - Accessors

/**
 *
 *
 */
- (void)showInWindow:(NSWindow *)window
{
	[mProgress startAnimation:nil];
	[NSApp beginSheet:mWindow modalForWindow:window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

/**
 *
 *
 */
- (void)setIndeterminateMode
{
	mIsIndeterminate = TRUE;
	[mProgress setIndeterminate:TRUE];
}

/**
 *
 *
 */
- (void)setPercent:(double)percent
{
	if (mIsIndeterminate) {
		[mProgress setMinValue:0.];
		[mProgress setMaxValue:1.];
		[mProgress setIndeterminate:FALSE];
		mIsIndeterminate = FALSE;
	}
	
	[mProgress setDoubleValue:percent];
}

/**
 *
 *
 */
- (void)hide
{
	[NSApp endSheet:mWindow];
}

/**
 *
 *
 */
- (void)setTitle:(NSString *)title
{
	[self.titleTxt setStringValue:title];
}

/**
 *
 *
 */
- (void)setSubtitle:(NSString *)subtitle
{
	[self.subtitleTxt setStringValue:subtitle];
}





#pragma mark - Callback

/**
 *
 *
 */
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
	[mWindow orderOut:self];
	[mProgress stopAnimation:nil];
}

@end
