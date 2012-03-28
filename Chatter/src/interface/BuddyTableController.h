//
//  BuddyTableController.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ChatterAccount;
@class ChatterObject;
@class ChatterPerson;

@interface BuddyTableController : NSViewController <NSTableViewDataSource, NSTableViewDataSource>
{
@private
	/* interface */
	NSTableView *__weak mTableView;
	
	/* data */
	NSMutableArray *mData;
	
	/* selection */
	NSTimeInterval mSelectionChangeTime;
	NSTimer *mSelectionTimer;
}

@property (readwrite, weak) IBOutlet NSTableView *tableView;

- (void)loadData;

- (void)deleteAccount:(ChatterAccount *)account;
- (void)deletePerson:(ChatterPerson *)person;
- (void)objectChanged:(ChatterObject *)object;

@end
