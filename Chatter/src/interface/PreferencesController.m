//
//  PreferencesController.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"

@implementation PreferencesController

@synthesize window = mWindow;
@synthesize tabView = mTabView;
@synthesize toolbar = mToolbar;





#pragma mark - Accessors

/**
 *
 *
 */
- (void)showInWindow:(NSWindow *)window
{
	[mToolbar setSelectedItemIdentifier:@"ChatterPreferenceGeneralItemIdentifier"];
	[mTabView selectTabViewItemWithIdentifier:@"1"];
	[NSApp beginSheet:mWindow modalForWindow:window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

/**
 *
 *
 */
- (void)hide
{
	[NSApp endSheet:mWindow];
}





#pragma mark - Callback

/**
 *
 *
 */
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
	[mWindow orderOut:self];
}





#pragma mark - Callbacks

/**
 *
 *
 */
- (void)doActionGeneral:(id)sender
{
	NSRect frame = mWindow.frame;
	frame.size.height = 300.;
	
	[mTabView selectTabViewItemWithIdentifier:@"1"];
	[mWindow setFrame:frame display:TRUE animate:TRUE];
}

/**
 *
 *
 */
- (void)doActionAppearance:(id)sender
{
	NSRect frame = mWindow.frame;
	frame.size.height = 350.;
	
	[mTabView selectTabViewItemWithIdentifier:@"2"];
	[mWindow setFrame:frame display:TRUE animate:TRUE];
}

/**
 *
 *
 */
- (void)doActionImporters:(id)sender
{
	NSRect frame = mWindow.frame;
	frame.size.height = 400.;
	
	[mTabView selectTabViewItemWithIdentifier:@"3"];
	[mWindow setFrame:frame display:TRUE animate:TRUE];
}

/**
 *
 *
 */
- (void)doActionExporters:(id)sender
{
	NSRect frame = mWindow.frame;
	frame.size.height = 450.;
	
	[mTabView selectTabViewItemWithIdentifier:@"4"];
	[mWindow setFrame:frame display:TRUE animate:TRUE];
}

/**
 *
 *
 */
- (void)doActionFacebook:(id)sender
{
	/*
	NSRect frame = mWindow.frame;
	frame.size.height = 450.;
	
	[mTabView selectTabViewItemWithIdentifier:@"4"];
	[mWindow setFrame:frame display:TRUE animate:TRUE];
	*/
}

/**
 *
 *
 */
- (void)doActionDone:(id)sender
{
	[self hide];
}





#pragma mark - Toolbar

/**
 *
 *
 */
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
					@"ChatterPreferenceGeneralItemIdentifier",
					@"ChatterPreferenceAppearanceItemIdentifier",
					@"ChatterPreferenceImportersItemIdentifier",
					@"ChatterPreferenceExportersItemIdentifier",
					@"ChatterPreferenceFacebookItemIdentifier",
					NSToolbarFlexibleSpaceItemIdentifier,
					@"ChatterPreferenceDoneItemIdentifier",
					nil];
	
}

/**
 *
 *
 */
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
					@"ChatterPreferenceGeneralItemIdentifier",
					@"ChatterPreferenceAppearanceItemIdentifier",
					@"ChatterPreferenceImportersItemIdentifier",
					@"ChatterPreferenceExportersItemIdentifier",
					@"ChatterPreferenceFacebookItemIdentifier",
					NSToolbarFlexibleSpaceItemIdentifier,
					@"ChatterPreferenceDoneItemIdentifier",
					nil];
}

/**
 *
 *
 */
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
					@"ChatterPreferenceGeneralItemIdentifier",
					@"ChatterPreferenceAppearanceItemIdentifier",
					@"ChatterPreferenceImportersItemIdentifier",
					@"ChatterPreferenceExportersItemIdentifier",
//				@"ChatterPreferenceFacebookItemIdentifier",
					nil];
}

/**
 *
 *
 */
- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)str willBeInsertedIntoToolbar:(BOOL)flag
{
	if ([str isEqualToString:@"ChatterPreferenceGeneralItemIdentifier"]) {
		NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:str] autorelease];
		
		[toolbarItem setLabel:@"General"];
		[toolbarItem setPaletteLabel:@"General"];
		
		[toolbarItem setToolTip:@"General preferences"];
		[toolbarItem setImage: [NSImage imageNamed:@"prefs-general"]];
		
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(doActionGeneral:)];
		
		return toolbarItem;
	}
	else if ([str isEqualToString:@"ChatterPreferenceAppearanceItemIdentifier"]) {
		NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:str] autorelease];
		
		[toolbarItem setLabel:@"Appearance"];
		[toolbarItem setPaletteLabel:@"Appearance"];
		
		[toolbarItem setToolTip:@"Font and style preferences"];
		[toolbarItem setImage: [NSImage imageNamed:@"prefs-appearance"]];
		
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(doActionAppearance:)];
		
		return toolbarItem;
	}
	else if ([str isEqualToString:@"ChatterPreferenceImportersItemIdentifier"]) {
		NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:str] autorelease];
		
		[toolbarItem setLabel:@"Importers"];
		[toolbarItem setPaletteLabel:@"Importers"];
		
		[toolbarItem setToolTip:@"Enable, disable and configure chat log importers"];
		[toolbarItem setImage: [NSImage imageNamed:@"prefs-import"]];
		
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(doActionImporters:)];
		
		return toolbarItem;
	}
	else if ([str isEqualToString:@"ChatterPreferenceExportersItemIdentifier"]) {
		NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:str] autorelease];
		
		[toolbarItem setLabel:@"Exporters"];
		[toolbarItem setPaletteLabel:@"Exporters"];
		
		[toolbarItem setToolTip:@"Enable, disable and configure chat log exporters"];
		[toolbarItem setImage: [NSImage imageNamed:@"prefs-export"]];
		
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(doActionExporters:)];
		
		return toolbarItem;
	}
	else if ([str isEqualToString:@"ChatterPreferenceFacebookItemIdentifier"]) {
		NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:str] autorelease];
		
		[toolbarItem setLabel:@"Facebook"];
		[toolbarItem setPaletteLabel:@"Facebook"];
		
		[toolbarItem setToolTip:@"Enable, disable Facebook access for getting names and pictures"];
		[toolbarItem setImage: [NSImage imageNamed:@"prefs-facebook"]];
		
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(doActionFacebook:)];
		
		return toolbarItem;
	}
	else if ([str isEqualToString:@"ChatterPreferenceDoneItemIdentifier"]) {
		NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:str] autorelease];
		NSButton *doneBtn = [[[NSButton alloc] init] autorelease];
		
		[doneBtn setButtonType:NSMomentaryPushInButton];
		[doneBtn setBezelStyle:NSRoundedBezelStyle];
		[doneBtn setTitle:@"Done"];
		[doneBtn setTarget:self];
		[doneBtn setAction:@selector(doActionDone:)];
		[doneBtn setBordered:TRUE];
		[doneBtn sizeToFit];
		
		[toolbarItem setView:doneBtn];
		
		return toolbarItem;
	}
	else {
		NSLog(@"%s.. identifier = %@", __PRETTY_FUNCTION__, str);
		return nil;
	}
}

@end
