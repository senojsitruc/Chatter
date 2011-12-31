//
//  BuddyEditController.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/ABGlobals.h>
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABTypedefs.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/ABPeoplePickerView.h>
#import <AddressBook/ABImageLoading.h>

@class ChatterAccount;
@class ChatterPerson;
@class BuddyEditPictureView;
@class BuddyTableController;
@class BuddyEditController;

@interface BuddyEditAccountsTableView : NSTableView
{
@public
	BuddyEditController *mController;
}
@end

@interface BuddyEditController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
{
@private
	/* interface - parent */
	IBOutlet BuddyTableController *mController;
	
	/* interface - edit window */
	IBOutlet NSTextField *mScreenNameTxt;
	IBOutlet BuddyEditPictureView *mProfileImg;
	IBOutlet NSTextField *mFirstNameTxt;
	IBOutlet NSTextField *mLastNameTxt;
	IBOutlet BuddyEditAccountsTableView *mAccountsTbl;
	IBOutlet NSScrollView *mAccountsView;
	IBOutlet NSButton *mOkayBtn;
	IBOutlet NSButton *mCancelBtn;
	IBOutlet NSButton *mChooseCardBtn;
	IBOutlet NSWindow *mWindow;
	
	/* interface - address card chooser */
	IBOutlet NSWindow *mAddressBookWindow;
	IBOutlet ABPeoplePickerView *mPeoplePicker;
	IBOutlet NSButton *mAddressBookChooseBtn;
	IBOutlet NSButton *mAddressBookCancelBtn;
	
	/* data */
	NSString *mAddressBookUid;
	ChatterAccount *mAccount;
	ChatterPerson *mPerson;
	NSMutableArray *mAccounts;
}

@property (readwrite, retain) ChatterAccount *account;
@property (readwrite, retain) ChatterPerson *person;

- (void)showInWindow:(NSWindow *)window;

@end
