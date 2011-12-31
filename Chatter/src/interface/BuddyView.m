//
//  BuddyView.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BuddyView.h"
#import "BuddyEditController.h"
#import "BuddyTableController.h"
#import "ChatterAccount+DBObject.h"
#import "ChatterMessage+DBObject.h"
#import "ChatterPerson+DBObject.h"
#import "ChatterObjectCache.h"
#import "ChatterAppDelegate.h"

@implementation BuddyView

@synthesize controller = mController;





#pragma mark - Structors

/**
 *
 *
 */
- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
		NSImage *image = [NSImage imageNamed:@"user-001.png"];
		image.size = NSMakeSize(32., 32.);
		
		mIconImg = [[NSImageView alloc] initWithFrame:NSMakeRect(5., 5., 32., 32.)];
		mIconImg.image = image;
//	[self addSubview:mIconImg];
		
		mNameTxt = [[NSTextField alloc] initWithFrame:NSMakeRect(5.+32.+10., (frame.size.height/2.)-8, frame.size.width-5.-32.-10., 16.)];
		[mNameTxt setBordered:FALSE];
		[mNameTxt setDrawsBackground:FALSE];
		[mNameTxt setBezeled:FALSE];
		[mNameTxt setEditable:FALSE];
		[mNameTxt setTextColor:[NSColor whiteColor]];
//	[mNameTxt setNextResponder:self];
//	[mNameTxt setRefusesFirstResponder:TRUE];
//	[mNameTxt setAcceptsTouchEvents:FALSE];
//	[self addSubview:mNameTxt];
	}
	
	return self;
}

/**
 *
 *
 */
- (void)dealloc
{
	[mIconImg release];
	[mNameTxt release];
	[mAccount release];
	
	[super dealloc];
}





#pragma mark - NSView

/**
 *
 *
 */
- (void)drawRect:(NSRect)dirtyRect
{
	mIconImg.bounds = mIconImg.frame;
	mNameTxt.bounds = mNameTxt.frame;
	
	[mIconImg drawRect:dirtyRect];
	[mNameTxt drawRect:dirtyRect];
}

/**
 * TODO: different options depending on whether this is a buddy or a person.
 *
 * Select address card
 * Delete
 * Rename
 *
 */
- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Buddy Menu"];
	NSString *name;
	
	if (mAccount)
		name = mAccount.screenname;
	else if (mPerson)
		name = mPerson.name;
	
	// rename
	{
		NSMenuItem *item = [menu addItemWithTitle:[NSString stringWithFormat:@"Edit %@...", name] action:@selector(doActionEdit:) keyEquivalent:@""];
		item.target = self;
	}
	
	// delete
	{
		NSMenuItem *item = [menu addItemWithTitle:[NSString stringWithFormat:@"Delete %@...", name] action:@selector(doActionDelete:) keyEquivalent:@""];
		item.target = self;
	}
	
	return [menu autorelease];
}





#pragma mark - Accessors

/**
 *
 *
 */
- (void)configureWithAccount:(ChatterAccount *)caccount
{
	if (mAccount == caccount)
		return;
	
	[mPerson release];
	mPerson = nil;
	
	[mAccount release];
	mAccount = [caccount retain];
	
	mIconImg.image = caccount.image;
	/*
	NSImage *image = [NSImage imageNamed:caccount.iconName];
	image.size = NSMakeSize(32., 32.);
	mIconImg.image = image;
	*/
	
//[mNameTxt setMenu:[self menuForEvent:nil]];
	[mNameTxt setStringValue:mAccount.screenname];
}

/**
 *
 *
 */
- (void)configureWithPerson:(ChatterPerson *)cperson
{
	if (mPerson == cperson)
		return;
	
	[mAccount release];
	mAccount = nil;
	
	[mPerson release];
	mPerson = [cperson retain];
	
	mIconImg.image = cperson.image;
	
	/*
	NSImage *image = [NSImage imageNamed:caccount.iconName];
	image.size = NSMakeSize(32., 32.);
	mIconImg.image = image;
	*/
	
//[mNameTxt setMenu:[self menuForEvent:nil]];
	[mNameTxt setStringValue:[NSString stringWithFormat:@"%@ %@", mPerson.firstName, mPerson.lastName]];
}





#pragma mark - Actions

/**
 *
 *
 */
- (void)doActionEdit:(id)sender
{
	BuddyEditController *buddyEditController = [ChatterAppDelegate appDelegate].buddyEditController;
	
	buddyEditController.account = mAccount;
	buddyEditController.person = mPerson;
	
	[buddyEditController showInWindow:self.window];
}

/**
 *
 *
 */
- (void)doActionDelete:(id)sender
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	NSString *name;
	
	if (mAccount)
		name = mAccount.screenname;
	else if (mPerson)
		name = mPerson.name;
	
	[alert setMessageText:[NSString stringWithFormat:@"Are you sure you want to delete '%@' and all associated messages?", name]];
	[alert setInformativeText:@"This action cannot be undone."];
	[alert addButtonWithTitle:@"Delete"];
	[alert addButtonWithTitle:@"Cancel"];
	
	[alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(deleteAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

/**
 *
 *
 */
- (void)deleteAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
	if (NSAlertFirstButtonReturn == returnCode) {
		if (mAccount)
			[mController deleteAccount:mAccount];
		else if (mPerson)
			[mController deletePerson:mPerson];
	}
	
	[[alert window] orderOut:self];
}

@end
