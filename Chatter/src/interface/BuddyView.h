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
	BuddyTableController *__unsafe_unretained mController;
	
	
	/* data */
	ChatterAccount *mAccount;
	ChatterPerson *mPerson;
}

@property (readwrite, unsafe_unretained) BuddyTableController *controller;

- (void)configureWithAccount:(ChatterAccount *)account;
- (void)configureWithPerson:(ChatterPerson *)person;

@end
