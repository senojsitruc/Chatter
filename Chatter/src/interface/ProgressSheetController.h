//
//  ProgressSheetController.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProgressSheetController : NSViewController
{
@private
	NSWindow *mWindow;
	NSTextField *mTitleTxt;
	NSProgressIndicator *mProgress;
	NSTextField *mSubtitleTxt;
	
	BOOL mIsIndeterminate;
}

@property (readwrite, strong) IBOutlet NSWindow *window;
@property (readwrite, strong) IBOutlet NSTextField *titleTxt;
@property (readwrite, strong) IBOutlet NSProgressIndicator *progress;
@property (readwrite, strong) IBOutlet NSTextField *subtitleTxt;

- (void)showInWindow:(NSWindow *)window;
- (void)hide;

- (void)setIndeterminateMode;
- (void)setPercent:(double)percent;

- (void)setTitle:(NSString *)title;
- (void)setSubtitle:(NSString *)subtitle;

@end
