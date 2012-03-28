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
	NSWindow *__unsafe_unretained mWindow;
	NSTabView *__weak mTabView;
	NSToolbar *__weak mToolbar;
	
	IBOutlet NSView *mGeneralView;
	IBOutlet NSView *mAppearanceView;
	IBOutlet NSView *mImportersView;
	IBOutlet NSView *mExportersView;
}

@property (readwrite, unsafe_unretained) IBOutlet NSWindow *window;
@property (readwrite, weak) IBOutlet NSTabView *tabView;
@property (readwrite, weak) IBOutlet NSToolbar *toolbar;

- (void)showInWindow:(NSWindow *)window;
- (void)hide;

@end
