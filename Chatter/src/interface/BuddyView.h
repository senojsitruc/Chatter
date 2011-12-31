//
//  BuddyView.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ChatterAccount;
@class ChatterPerson;
@class BuddyTableController;

@interface BuddyView : NSView
{
@private
	/* interface */
	NSImageView *mIconImg;
	NSTextField *mNameTxt;
	BuddyTableController *mController;
	
	
	/* data */
	ChatterAccount *mAccount;
	ChatterPerson *mPerson;
}

@property (readwrite, assign) BuddyTableController *controller;

- (void)configureWithAccount:(ChatterAccount *)account;
- (void)configureWithPerson:(ChatterPerson *)person;

@end
