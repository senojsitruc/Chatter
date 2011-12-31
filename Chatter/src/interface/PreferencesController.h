//
//  PreferencesController.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSViewController <NSToolbarDelegate>
{
@private
	NSWindow *mWindow;
	NSTabView *mTabView;
	NSToolbar *mToolbar;
	
	IBOutlet NSView *mGeneralView;
	IBOutlet NSView *mAppearanceView;
	IBOutlet NSView *mImportersView;
	IBOutlet NSView *mExportersView;
}

@property (readwrite, assign) IBOutlet NSWindow *window;
@property (readwrite, assign) IBOutlet NSTabView *tabView;
@property (readwrite, assign) IBOutlet NSToolbar *toolbar;

- (void)showInWindow:(NSWindow *)window;
- (void)hide;

@end
