//
//  BuddyTableController.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BuddyTableController.h"
#import "ChatterAccount+DBObject.h"
#import "ChatterMessage+DBObject.h"
#import "ChatterObject.h"
#import "ChatterObjectCache.h"
#import "ChatterPerson+DBObject.h"
#import "BuddyView.h"
#import "Easy.h"

@interface BuddyTableController (PrivateMethods)
- (void)reloadTable;
@end





@implementation BuddyTableController

@synthesize tableView = mTableView;





#pragma mark - Structors

/**
 *
 *
 */
- (void)awakeFromNib
{
	mData = [[NSMutableArray alloc] init];
	[mTableView setRowHeight:38.];
	mSelectionChangeTime = 0.;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doHandleDeselectAllNotification:) name:@"ChatterNotificationBuddyListDeselectAll" object:nil];
}

/**
 *
 *
 */
- (void)dealloc
{
	[mData release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}





#pragma mark - Accessors

/**
 *
 *
 */
- (void)loadData
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableIndexSet *insertedIndexes = [NSMutableIndexSet indexSet];
	NSMutableIndexSet *removedIndexes = [NSMutableIndexSet indexSet];
	NSMutableIndexSet *personIds = [NSMutableIndexSet indexSet];
	NSMutableArray *buddies = [NSMutableArray array];
	ChatterObjectCache *cache = [ChatterObjectCache sharedInstance];
	
	// form a distinct list of all of the person-ids that should be visible; and a distinct list of
	// all of the accounts that do not have person associations
	for (ChatterAccount *caccount in [cache allAccounts]) {
		if (caccount.personId != 0)
			[personIds addIndex:caccount.personId];
		else
			[buddies addObject:caccount];
	}
	
	// for each person-id, get the associated person object
	[personIds enumerateIndexesUsingBlock:^ (NSUInteger personId, BOOL *stop) {
		[buddies addObject:[cache personForId:personId]];
	}];
	
	// sort the buddies (accounts and persons) alphabetically, ascending.
	[buddies setArray:[buddies sortedArrayUsingComparator:^ NSComparisonResult (id obj1, id obj2) {
		NSString *name1=nil, *name2=nil;
		
		if ([obj1 isKindOfClass:[ChatterAccount class]])
			name1 = ((ChatterAccount *)obj1).screenname;
		else if ([obj1 isKindOfClass:[ChatterPerson class]])
			name1 = ((ChatterPerson *)obj1).name;
		
		if ([obj2 isKindOfClass:[ChatterAccount class]])
			name2 = ((ChatterAccount *)obj2).screenname;
		else if ([obj2 isKindOfClass:[ChatterPerson class]])
			name2 = ((ChatterPerson *)obj2).name;
		
		return [name1 compare:name2];
	}]];
	
	{
		NSMutableIndexSet *oldIds = [NSMutableIndexSet indexSet];
		NSMutableIndexSet *newIds = [NSMutableIndexSet indexSet];
		NSUInteger index = 0;
		
		// collect the ids of all of the persons and accounts in the old data set
		for (ChatterObject *cobject in mData) {
			NSUInteger databaseId = cobject.databaseId;
			
			if ([cobject isKindOfClass:[ChatterPerson class]])
				databaseId += 10000000;
			
			[oldIds addIndex:databaseId];
		}
		
		// collect the ids of all of the persons and accounts in the new data set
		for (ChatterObject *cobject in buddies) {
			NSUInteger databaseId = cobject.databaseId;
			
			if ([cobject isKindOfClass:[ChatterPerson class]])
				databaseId += 10000000;
			
			[newIds addIndex:databaseId];
		}
		
		index = 0;
		
		// note the indexes of the objects in the old data that are not in the new data set (removed)
		for (ChatterObject *cobject in mData) {
			NSUInteger databaseId = cobject.databaseId;
			
			if ([cobject isKindOfClass:[ChatterPerson class]])
				databaseId += 10000000;
			
			if (![newIds containsIndex:databaseId])
				[removedIndexes addIndex:index];
			
			index += 1;
		}
		
		index = 0;
		
		// note the indexes of the objects in the new data set that are not in the old data set (inserted)
		for (ChatterObject *cobject in buddies) {
			NSUInteger databaseId = cobject.databaseId;
			
			if ([cobject isKindOfClass:[ChatterPerson class]])
				databaseId += 10000000;
			
			if (![oldIds containsIndex:databaseId])
				[insertedIndexes addIndex:index];
			
			index += 1;
		}
	}
	
	if ([mData count] != [buddies count]) {
		[mData release];
		mData = [buddies retain];
		[self reloadTable];
	}
	else {
		[mData release];
		mData = [buddies retain];
		
		[mTableView removeRowsAtIndexes:removedIndexes withAnimation:NSTableViewAnimationEffectFade];
		[mTableView insertRowsAtIndexes:insertedIndexes withAnimation:NSTableViewAnimationEffectFade];
	}
	
	[pool release];
}

/**
 *
 *
 */
- (void)reloadTable
{
	[mTableView scrollRowToVisible:0];
	[mTableView noteNumberOfRowsChanged];
	[mTableView reloadData];
}

/**
 *
 *
 */
- (void)deleteAccount:(ChatterAccount *)caccount
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableIndexSet *messageIds = [NSMutableIndexSet indexSet];
	NSMutableArray *messages = [NSMutableArray array];
	ChatterObjectCache *cache = [ChatterObjectCache sharedInstance];
	NSInteger tableRow = [mData indexOfObject:caccount];
	
	// obtain all of the ids for all of the messages belonging to this account
	[ChatterMessage dbobjectSelectIDsForAccount:caccount withHandler:(^ BOOL (NSUInteger messageId) {
		[messageIds addIndex:messageId];
		return TRUE;
	})];
	
	// create an array of all of the message objects
	[messageIds enumerateIndexesUsingBlock:(^ (NSUInteger messageId, BOOL *stop) {
		ChatterMessage *cmessage = [cache messageForId:messageId];
		
		if (cmessage != nil)
			[messages addObject:cmessage];
	})];
	
	// delete the account from the database
	if (FALSE == [caccount dbobjectDelete]) {
		NSLog(@"%s.. failed to Account::dbobjectDelete()", __PRETTY_FUNCTION__);
		goto done;
	}
	
	// remove all of the messages from the object cache
	for (ChatterMessage *cmessage in messages)
		[cache removeObject:cmessage];
	
	// remove the account from the object cache
	[cache removeObject:caccount];
	
	// remove the account from the table view and update the table
	if (tableRow >= 0) {
		[mData removeObjectAtIndex:tableRow];
		[mTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:tableRow] withAnimation:TRUE];
	}
	
done:
	[pool release];
}

/**
 *
 *
 */
- (void)deletePerson:(ChatterPerson *)cperson
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableIndexSet *messageIds = [NSMutableIndexSet indexSet];
	NSMutableArray *messages = [NSMutableArray array];
	ChatterObjectCache *cache = [ChatterObjectCache sharedInstance];
	NSInteger tableRow = [mData indexOfObject:cperson];
	
	// obtain all of the ids for all of the messages belonging to this person
	[ChatterMessage dbobjectSelectIDsForPerson:cperson withHandler:(^ BOOL (NSUInteger messageId) {
		[messageIds addIndex:messageId];
		return TRUE;
	})];
	
	// create an array of all of the message objects
	[messageIds enumerateIndexesUsingBlock:(^ (NSUInteger messageId, BOOL *stop) {
		ChatterMessage *cmessage = [cache messageForId:messageId];
		
		if (cmessage != nil)
			[messages addObject:cmessage];
	})];
	
	// delete the person from the database; this also deletes all of the linked records
	if (FALSE == [cperson dbobjectDelete]) {
		NSLog(@"%s.. failed to Person::dbobjectDelete()", __PRETTY_FUNCTION__);
		goto done;
	}
	
	// remove all of the messages from the object cache
	for (ChatterMessage *cmessage in messages)
		[cache removeObject:cmessage];
	
	// remove all of the person's accounts from the object cache
	for (ChatterAccount *caccount in [cache allAccounts]) {
		if (caccount.personId == cperson.databaseId)
			[cache removeObject:caccount];
	}
	
	// remove the person from the object cache
	[cache removeObject:cperson];
	
	// remove the person from the table view and update the table
	if (tableRow >= 0) {
		[mData removeObjectAtIndex:tableRow];
		[mTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:tableRow] withAnimation:TRUE];
	}
	
done:
	[pool release];
}

/**
 * Either a ChatterAccount or a ChatterPerson
 *
 */
- (void)objectChanged:(ChatterObject *)cobject
{
	[self loadData];
}





#pragma mark - Notifications

/**
 *
 *
 */
- (void)doHandleDeselectAllNotification:(NSNotification *)notification
{
	[mTableView deselectAll:self];
}

/**
 *
 *
 */
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	mSelectionChangeTime = [NSDate timeIntervalSinceReferenceDate];
	
	if (mSelectionTimer == nil)
		mSelectionTimer = [[NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(doSelectionChangedTimer:) userInfo:nil repeats:TRUE] retain];
}

/**
 *
 *
 */
- (void)doSelectionChangedTimer:(NSTimer *)timer
{
	if (mSelectionChangeTime + .5 > [NSDate timeIntervalSinceReferenceDate])
		return;
	
	[mSelectionTimer invalidate];
	[mSelectionTimer release];
	mSelectionTimer = nil;
	
	[Easy postNotification:@"ChatterNotificationBuddySelectionChanged" object:[mData objectsAtIndexes:[mTableView selectedRowIndexes]]];
}




#pragma mark - NSTableViewDataSource

/**
 *
 *
 */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [mData count];
}

/**
 *
 *
 */
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if (rowIndex >= 0 && rowIndex < [mData count])
		return [mData objectAtIndex:rowIndex];
	else
		return nil;
}





#pragma mark - NSTableViewDelegate

/**
 *
 *
 */
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	BuddyView *view = [tableView makeViewWithIdentifier:@"BuddyView" owner:self];
	ChatterObject *cobject = [mData objectAtIndex:row];
	
	if (view == nil) {
		CGRect tableFrame = [tableView frame];
		view = [[[BuddyView alloc] initWithFrame:NSMakeRect(0., 0., tableFrame.size.width, 38.)] autorelease];
		view.identifier = @"BuddyView";
		view.controller = self;
	}
	
	if ([cobject isKindOfClass:[ChatterAccount class]])
		[view configureWithAccount:(ChatterAccount *)cobject];
	else
		[view configureWithPerson:(ChatterPerson *)cobject];
	
	return view;
}

/**
 *
 *
 */
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	return 38.;
}

@end
