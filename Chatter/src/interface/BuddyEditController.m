//
//  BuddyEditController.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BuddyEditController.h"
#import "ChatterAccount+DBObject.h"
#import "ChatterPerson+DBObject.h"
#import "ChatterObjectCache.h"
#import "BuddyEditPictureView.h"
#import "BuddyTableController.h"

@interface BuddyEditController (PrivateMethods)
- (void)doActionDeleteAccountAtRow:(NSInteger)row;
@end





@implementation BuddyEditAccountsTableView

- (void)keyDown:(NSEvent *)theEvent
{
	unsigned short keyCode = theEvent.keyCode;
	
	if (keyCode == 51)
		[mController doActionDeleteAccountAtRow:[self selectedRow]];
}

@end





@implementation BuddyEditController

@synthesize account = mAccount;
@synthesize person = mPerson;





#pragma mark - Structors

/**
 *
 *
 */
- (void)awakeFromNib
{
	[mProfileImg setEditable:TRUE];
	mAccounts = [[NSMutableArray alloc] init];
	mAccountsTbl->mController = self;
}

/**
 *
 *
 */
- (void)dealloc
{
	[mAccount release];
	[mPerson release];
	[mAccounts release];
	
	[super dealloc];
}





#pragma mark - Accessors

/**
 * Account Mode:
 *   Window Height: 221
 *   Buttons Y: 20
 *
 * Person Mode:
 *   Window Height: 406
 *   Buttons Y: 20
 *
 */
- (void)showInWindow:(NSWindow *)window
{
	NSString *name, *firstName, *lastName;
	NSImage *image;
	
	if (mAccount) {
		name = mAccount.screenname;
		firstName = mAccount.person.firstName;
		lastName = mAccount.person.lastName;
		image = mAccount.image;
		[mAccountsView setHidden:TRUE];
		[mWindow setFrame:NSMakeRect(mWindow.frame.origin.x, mWindow.frame.origin.y, mWindow.frame.size.width, 245.) display:TRUE animate:FALSE];
	}
	else if (mPerson) {
		name = mPerson.name;
		firstName = mPerson.firstName;
		lastName = mPerson.lastName;
		image = mPerson.image;
		[mAccountsView setHidden:FALSE];
		[mAccountsTbl setFrame:NSMakeRect(18., 78., 277., 135.)];
		[mAccounts removeAllObjects];
		
		[mAccounts setArray:[[[ChatterObjectCache sharedInstance] allAccounts] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^ BOOL (id obj, NSDictionary *bindings) {
			return ((ChatterAccount *)obj).personId == mPerson.databaseId;
		}]]];
		
		[mAccountsTbl reloadData];
		[mWindow setFrame:NSMakeRect(mWindow.frame.origin.x, mWindow.frame.origin.y, mWindow.frame.size.width, 406) display:TRUE animate:FALSE];
	}
	else
		return;
	
	if (!firstName)
		firstName = @"";
	
	if (!lastName)
		lastName = @"";
	
	[mScreenNameTxt setStringValue:name];
	[mFirstNameTxt setStringValue:firstName];
	[mLastNameTxt setStringValue:lastName];
	mProfileImg.image = image;
	
	[mWindow makeFirstResponder:mFirstNameTxt];
	
	[NSApp beginSheet:mWindow modalForWindow:window modalDelegate:self didEndSelector:@selector(editSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

/**
 *
 *
 */
- (void)editSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
	[sheet orderOut:self];
}





#pragma mark - Callbacks

/**
 * TODO: address card support
 *
 */
- (IBAction)doActionOkay:(id)sender
{
	NSString *firstName = [[mFirstNameTxt stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSString *lastName = [[mLastNameTxt stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if (mAccount) {
		ChatterPerson *person = nil;
		
		if ([firstName length] == 0 && [lastName length] == 0) {
			if (mAccount.personId != 0) {
				mAccount.personId = 0;
				[mAccount dbobjectUpdate];
			}
			
			mAccount.image = mProfileImg.image;
		}
		else {
			person = [ChatterPerson dbobjectSelectByFirstName:firstName andLastName:lastName];
			
			if (person == nil) {
				person = [ChatterPerson person];
				person.firstName = firstName;
				person.lastName = lastName;
				[person dbobjectInsert];
				person.image = mProfileImg.image;
				[person dbobjectUpdate];
				[[ChatterObjectCache sharedInstance] addObject:person];
			}
			else
				person.image = mProfileImg.image;
			
			if (mAccount.personId != person.databaseId) {
				mAccount.personId = person.databaseId;
				[mAccount dbobjectUpdate];
			}
		}
		
		[mController objectChanged:mAccount];
	}
	else if (mPerson) {
		mPerson.firstName = firstName;
		mPerson.lastName = lastName;
		mPerson.image = mProfileImg.image;
		[mPerson dbobjectUpdate];
		
		[mController objectChanged:mPerson];
	}
	
done:
	[NSApp endSheet:mWindow];
}

/**
 *
 *
 */
- (IBAction)doActionCancel:(id)sender
{
	[NSApp endSheet:mWindow];
}

/**
 * TODO: select the current card (if any) before displaying the people picker
 *
 */
- (IBAction)doActionChooseCard:(id)sender
{
	[mPeoplePicker clearSearchField:self];
	
	[NSApp beginSheet:mAddressBookWindow modalForWindow:mWindow modalDelegate:self didEndSelector:@selector(chooseSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

/**
 *
 *
 */
- (void)chooseSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
	[sheet orderOut:self];
}

/**
 *
 *
 */
- (IBAction)doActionAddressBookCancel:(id)sender
{
	[NSApp endSheet:mAddressBookWindow];
}

/**
 * ABPerson (0x10748f890) {
 *   ABPersonFlags  : 0
 *   AIMInstant     : {
 *     home  Tremelune  D6DFAB68-B216-4A58-A020-F5492FF8539E
 *   }
 *   Creation       : 2010-12-09 20:25:30 +0000
 *   Email          : {
 *     work  wbenedict@limewire.com  B0CFB72B-4D4D-4D7D-9298-33CD8A524325
 *   }
 *   First          : Will
 *   InstantMessage : {
 *     home  {
 *       InstantMessageService = AIMInstant;
 *       InstantMessageUsername = Tremelune;
 *     }  D6DFAB68-B216-4A58-A020-F5492FF8539E
 *   }
 *   JobTitle       : Software Developer
 *   Last           : Benedict
 *   Modification   : 2010-12-13 05:53:46 +0000
 *   Organization   : Lime Wire
 *   Parent Groups  : Limers (0x10029fac0), Garbage (0x1002a02c0)
 *   Phone          : {
 *     mobile  617-470-8408  C9B6F5FA-93A1-409C-A52C-57E80835D807
 *   }
 *   Private        : <ABCDContact 0x10770e0b0>
 *   Store          : ~/Library/Application Support/AddressBook/AddressBook-v22.abcddb
 *   Unique ID      : 03123C25-F7F8-43A0-88CE-3A9612B912B0:ABPerson
 * }
 *
 */
- (IBAction)doActionAddressBookChoose:(id)sender
{
	NSArray *selections = [mPeoplePicker selectedRecords];
	
	if ([selections count] == 0)
		return;
	
	for (NSObject *object in selections) {
		if ([object isKindOfClass:[ABPerson class]]) {
			ABPerson *abperson = (ABPerson *)object;
			
			[mAddressBookUid release];
			mAddressBookUid = [[abperson valueForProperty:kABUIDProperty] retain];
			
			NSString *abfirst = [abperson valueForProperty:kABFirstNameProperty];
			NSString *ablast = [abperson valueForProperty:kABLastNameProperty];
			NSData *imageData = [abperson imageData];
			
			[mFirstNameTxt setStringValue:abfirst];
			[mLastNameTxt setStringValue:ablast];
			
			if (imageData)
				[mProfileImg setImage:[[[NSImage alloc] initWithData:imageData] autorelease]];
			else
				[mProfileImg setImage:nil];
			
			break;
		}
	}
	
	[NSApp endSheet:mAddressBookWindow];
}

/**
 *
 *
 */
- (void)doActionDeleteAccountAtRow:(NSInteger)row
{
	if (row >= 0 && row < [mAccounts count]) {
		ChatterAccount *caccount = [mAccounts objectAtIndex:row];
		caccount.person = nil;
		[caccount dbobjectUpdate];
		
		[mAccounts removeObjectAtIndex:row];
		[mAccountsTbl removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationEffectFade];
	}
}





#pragma mark - NSTableViewDataSource

/**
 *
 *
 */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [mAccounts count];
}





#pragma mark - NSTableViewDelegate

/**
 *
 *
 */
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTextField *view = [tableView makeViewWithIdentifier:@"AccountView" owner:self];
	ChatterAccount *caccount = [mAccounts objectAtIndex:row];
	
	if (view == nil) {
		CGRect tableFrame = [tableView frame];
		
		view = [[NSTextField alloc] initWithFrame:NSMakeRect(0., 0., tableFrame.size.width, tableFrame.size.height)];
		[view setBordered:FALSE];
		[view setDrawsBackground:FALSE];
		[view setBezeled:FALSE];
		[view setEditable:FALSE];
		view.identifier = @"AccountView";
	}
	
	view.stringValue = caccount.screenname;
	
	return view;
}

/**
 *
 *
 */
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	return 17.;
}

@end
