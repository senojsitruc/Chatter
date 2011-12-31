//
//  AboutController.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AboutController.h"
#import "ChatterAppDelegate.h"

@implementation AboutController

/**
 *
 *
 */
- (void)awakeFromNib
{
	NSBundle *mainBundle = [NSBundle mainBundle];
	
	mIsShowingChangelog = FALSE;
	
	{
		NSData *rtfData = [[NSData alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Credits" ofType:@"rtf"]];
		NSAttributedString *content = [[NSAttributedString alloc] initWithRTF:rtfData documentAttributes:NULL];
		
		[mAboutTxt setRichText:TRUE];
		[mAboutTxt setEditable:FALSE];
//	[mAboutTxt setSelectable:FALSE];
		[[mAboutTxt textStorage] setAttributedString:content];
		
		[rtfData release];
		[content release];
	}
	
	// CFBundleIconFile (Chatter.icns)
	{
		NSDictionary *appInfo = [mainBundle infoDictionary];
		NSString *version = [appInfo objectForKey:@"CFBundleShortVersionString"];
		NSString *build = [appInfo objectForKey:(NSString *)kCFBundleVersionKey];
		
		[mVersionTxt setStringValue:[NSString stringWithFormat:@"v%@ (%@)", version, build]];
	}
}

/**
 * 509 x 381
 *
 */
- (IBAction)doActionChangelog:(id)sender
{
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *file;
	NSRect frame = mPanel.frame;
	
	if (mIsShowingChangelog) {
		file = @"Credits";
		frame.size.width = 509;
		frame.size.height = 381;
	}
	else {
		file = @"Changelog";
		frame.size.width = 600;
		frame.size.height = 381;
	}
	
	{
		NSData *rtfData = [[NSData alloc] initWithContentsOfFile:[mainBundle pathForResource:file ofType:@"rtf"]];
		NSAttributedString *content = [[NSAttributedString alloc] initWithRTF:rtfData documentAttributes:NULL];
		
		[mAboutTxt setRichText:TRUE];
		[mAboutTxt setEditable:FALSE];
		[[mAboutTxt textStorage] setAttributedString:content];
		
		[rtfData release];
		[content release];
	}
	
	mIsShowingChangelog = !mIsShowingChangelog;
	
	[mPanel setFrame:frame display:TRUE animate:TRUE];
}

/**
 *
 *
 */
- (IBAction)doActionFeedback:(id)sender
{
	[[ChatterAppDelegate appDelegate] performSelectorOnMainThread:@selector(doActionFeedback:) withObject:self waitUntilDone:FALSE];
}

/**
 *
 *
 */
- (IBAction)doActionWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://curtisjones.us"]];	
}

/**
 *
 *
 */
- (IBAction)show:(id)sende0
{
	[mPanel makeKeyAndOrderFront:self];
}

/**
 *
 *
 */
- (IBAction)hide:(id)sender
{
	
}

@end
