//
//  MessageTableController.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageTableController.h"
#import "ChatterAccount+DBObject.h"
#import "ChatterMessage+DBObject.h"
#import "ChatterMessageWord+DBObject.h"
#import "ChatterPerson+DBObject.h"
#import "ChatterSource.h"
#import "ChatterSessionAccount+DBObject.h"
#import "ChatterObjectCache.h"
#import "MessageSearch.h"
#import "MessageView.h"
#import "MessageGroupView.h"
#import "MessageTabView.h"
#import "Easy.h"

@interface MessageTableController (PrivateMethods)
- (NSView *)__tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
@end

@implementation MessageTableController

@synthesize tableView = mTableView;





#pragma mark - Structors

/**
 *
 *
 */
- (void)awakeFromNib
{
	mData = [[NSMutableArray alloc] init];
	mVisibleCount = mVisibleCount2 = 0;
	mLastQueryChange = 0.;
	
	mIsSearched = FALSE;
	mIsFiltered = FALSE;
	
	mIsGroupedByChat = TRUE;
	mIsGroupedByPerson = FALSE;
	
	mIsSortedByDate = TRUE;
	mIsSortedByPerson = FALSE;
	
	mIsSortedAscending = FALSE;
	mIsSortedDescending = TRUE;
	
	mStopRendering = FALSE;
	mStopFiltering = FALSE;
	mStopSearching = FALSE;
	
	mSortOpt.target = self;
	mSortOpt.action = @selector(doActionSortOption:);
	
	mGroupOpt.target = self;
	mGroupOpt.action = @selector(doActionGroupOption:);
	[mGroupOpt setSelected:TRUE forSegment:0];
	[mGroupOpt setSelected:FALSE forSegment:1];
	
	mGroupByChatTab.isSelected = TRUE;
	mGroupByPersonTab.isSelected = FALSE;
	
	mGroupByChatTab.handler = [^ (MessageTabView *mtv) {
		if (!mGroupByChatTab.isSelected) {
			mGroupByChatTab.isSelected = TRUE;
			mGroupByPersonTab.isSelected = FALSE;
		}
	} copy];
	
	mGroupByPersonTab.handler = [^ (MessageTabView *mtv) {
		if (!mGroupByPersonTab.isSelected) {
			mGroupByChatTab.isSelected = FALSE;
			mGroupByPersonTab.isSelected = TRUE;
		}
	} copy];
	
	[mTableView setBackgroundColor:[NSColor colorWithDeviceRed:0x3B/256. green:0x3B/256. blue:0x3B/256. alpha:1.]];
	
	mBubbleSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	mBubbleIndex = 0;
	mBubbleCount = 0;
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){0.914, 0.82, 0.18, 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){0.72, 0.7578, 0.789, 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0x21/256., (float)0xBF/256., (float)0x41/256., 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0xBF/256., (float)0x4C/256., (float)0xA9/256., 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0x30/256., (float)0x77/256., (float)0xBF/256., 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0x06/256., (float)0xB5/256., (float)0xBF/256., 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0xBF/256., (float)0xBE/256., (float)0x88/256., 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0xBF/256., (float)0x00/256., (float)0x00/256., 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0xFF/256., (float)0x70/256., (float)0xDB/256., 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0xCC/256., (float)0xFF/256., (float)0x50/256., 1.0});
	mBubbleColorsByAccountId = [[NSMutableDictionary alloc] init];
	mBubbleColorsByPersonId = [[NSMutableDictionary alloc] init];
	
	[mTableView setFloatsGroupRows:TRUE];
	
	mRenderSem = dispatch_semaphore_create(0);
	mSearchSem = dispatch_semaphore_create(0);
	mFilterSem = dispatch_semaphore_create(0);
	
	// persistent threads that handle searching and filtering
	[NSThread detachNewThreadSelector:@selector(renderThread) toTarget:self withObject:nil];
	[NSThread detachNewThreadSelector:@selector(searchThread) toTarget:self withObject:nil];
	[NSThread detachNewThreadSelector:@selector(filterThread) toTarget:self withObject:nil];
	
	// notifications that let us know about changes to the search query or buddy selection
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doHandleSearchQueryChangedNotification:) name:@"ChatterNotificationSearchQueryChanged" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doHandleBuddySelectionChanged:) name:@"ChatterNotificationBuddySelectionChanged" object:nil];
}

/**
 *
 *
 */
- (void)dealloc
{
	[mData release];
	[mVisibleData release];
	[mTmpVisibleData release];
	
	CGColorSpaceRelease(mBubbleSpace);
	CGColorRelease(mBubbleColors[0]);
	CGColorRelease(mBubbleColors[1]);
	[mBubbleColorsByAccountId release];
	[mBubbleColorsByPersonId release];
	
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
	NSArray *messages = [[ChatterObjectCache sharedInstance] allMessages];	
	
	[mData removeAllObjects];
	[mData setArray:messages];
	
	dispatch_semaphore_signal(mRenderSem);
	
	[pool release];
}

/**
 *
 *
 */
- (void)resize
{
	if (mVisibleCount2 > 100) {
		mVisibleCount2 = MIN(100, mVisibleCount);
		
		[mTableView scrollRowToVisible:0];
		[mTableView noteNumberOfRowsChanged];
		[mTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.];
	}
}

/**
 * Takes the filtered data and/or the searched data and performs grouping and sorting as necessary.
 *
 */
- (void)renderThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	while (!mStopRendering) {
		dispatch_semaphore_wait(mRenderSem, DISPATCH_TIME_FOREVER);
		
		NSArray *visibleData = nil;
		NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
		
		[Easy postNotification:@"ChatterNotificationProgressTextChanged" object:@"Rendering..."];
		
		// obtain the messages set which will become our new visible message set. this means finding
		// the overlap of the search data set and the filtered data set (as applicable).
		{
			if (mIsSearched && mIsFiltered) {
				NSArray *messages;
				NSIndexSet *messageIds;
				NSMutableArray *newData = [NSMutableArray array];
				
				if ([mSearchData count] <= [mFilterData count]) {
					messages = [mSearchData retain];
					messageIds = [mFilterIds retain];
				}
				else {
					messages = [mFilterData retain];
					messageIds = [mSearchIds retain];
				}
				
				[messages release];
				[messageIds release];
				
				for (ChatterMessage *cmessage in messages) {
					if (mStopRendering)
						goto done;
					if ([messageIds containsIndex:cmessage.databaseId])
						[newData addObject:cmessage];
				}
				
				visibleData = newData;
			}
			else if (mIsSearched)
				visibleData = mSearchData;
			else if (mIsFiltered)
				visibleData = mFilterData;
			else
				visibleData = mData;
		}
		
		// group by person. first sort the messages by the name of the sender and then insert markers
		// (NSNull's) indicating the start of each message group.
		if (mIsGroupedByPerson)
		{
			NSArray *messages;
			
			messages = [[visibleData sortedArrayUsingComparator:(^ NSComparisonResult (id obj1, id obj2) {
				ChatterAccount *account1, *account2;
				NSString *name1, *name2;
				
				account1 = ((ChatterMessage *)obj1).account;
				account2 = ((ChatterMessage *)obj2).account;
				
				name1 = account1.person.name;
				name2 = account2.person.name;
				
				if (name1 == nil)
					name1 = account1.screenname;
				
				if (name2 == nil)
					name2 = account2.screenname;
				
				return mIsSortedAscending ? [name1 compare:name2] : [name2 compare:name1];
			})] retain];
			
			if ([messages count] != 0) {
				NSMutableArray *tmpVisibleData = [NSMutableArray array];
				NSUInteger participantId = 0;
				
				for (ChatterMessage *cmessage in messages) {
					ChatterAccount *caccount = cmessage.account;
					ChatterPerson *cperson = caccount.person;
					NSUInteger theId;
					
					if (mStopRendering)
						goto done;
					
					if (cperson != nil)
						theId = cperson.databaseId;
					else
						theId = caccount.databaseId;
					
					if (theId != participantId) {
						[tmpVisibleData addObject:[NSNull null]];
						participantId = theId;
					}
					
					[tmpVisibleData addObject:cmessage];
				}
				
				visibleData = tmpVisibleData;
			}
		}
		
		// group by chat and sort by date. fist sort the messages by date, then if we want the messages
		// sorted ascending just insert the NSNull message group markers and we're done. if we want the
		// messages sorted descending split the messages into arrays of individual conversations. sort
		// the conversations (descending). merge the conversations together with the group markers.
		else if (mIsGroupedByChat)
		{
			NSArray *messages;
			
			messages = [[visibleData sortedArrayUsingComparator:(^ NSComparisonResult (id obj1, id obj2) {
				ChatterSource *source1, *source2;
				
				source1 = ((ChatterMessage *)obj1).source;
				source2 = ((ChatterMessage *)obj2).source;
				
				return [source1.timestampStr compare:source2.timestampStr];
			})] retain];
			
			if ([messages count] != 0) {
				NSMutableArray *tmpVisibleData = [NSMutableArray array];
				NSUInteger sourceId = 0;
				
				// sort ascending
				if (mIsSortedAscending) {
					for (ChatterMessage *cmessage in messages) {
						NSUInteger theId = cmessage.sourceId;
						
						if (mStopRendering)
							goto done;
						
						if (theId != sourceId) {
							[tmpVisibleData addObject:[NSNull null]];
							sourceId = theId;
						}
						
						[tmpVisibleData addObject:cmessage];
					}
				}
				
				// sort descending
				else if (mIsSortedDescending) {
					NSMutableArray *conversations = [NSMutableArray array];
					NSMutableArray *conversation = nil;
					
					// split up the messages by conversation
					for (ChatterMessage *cmessage in messages) {
						NSUInteger theId = cmessage.sourceId;
						
						if (mStopRendering)
							goto done;
						
						if (theId != sourceId) {
							if (conversation != nil)
								[conversations addObject:conversation];
							conversation = [NSMutableArray array];
							sourceId = theId;
						}
						
						[conversation addObject:cmessage];
					}
					
					if (conversation != nil)
						[conversations addObject:conversation];
					
					// sort the messages within each conversation - ascending
					for (NSMutableArray *conversation in conversations) {
						if (mStopRendering)
							goto done;
						[conversation setArray:[conversation sortedArrayUsingComparator:(^ NSComparisonResult (id obj1, id obj2) {
							return [((ChatterMessage *)obj1).timestampStr compare:((ChatterMessage *)obj2).timestampStr];
						})]];
					}
					
					// sort the conversations - descending
					[conversations setArray:[conversations sortedArrayUsingComparator:(^ NSComparisonResult (id obj1, id obj2) {
						return [((ChatterMessage *)[(NSArray *)obj2 objectAtIndex:0]).timestampStr compare:((ChatterMessage *)[(NSArray *)obj1 objectAtIndex:0]).timestampStr];
					})]];
					
					// merge the conversations together
					for (NSArray *conversation in conversations) {
						if (mStopRendering)
							goto done;
						[tmpVisibleData addObject:[NSNull null]];
						[tmpVisibleData addObjectsFromArray:conversation];
					}
				}
				
				visibleData = tmpVisibleData;
			}
		}
		
		// sort the messages by date
		else if (mIsSortedByDate)
		{
			// sort by date ascending (chronological)
			if (mIsSortedAscending) {
				visibleData = [[visibleData sortedArrayUsingComparator:(^ NSComparisonResult (id obj1, id obj2) {
					return [((ChatterMessage *)obj1).timestampStr compare:((ChatterMessage *)obj2).timestampStr];
				})] retain];
			}
			
			// sort by date descending (reverse chronological)
			else if (mIsSortedDescending) {
				visibleData = [[visibleData sortedArrayUsingComparator:(^ NSComparisonResult (id obj1, id obj2) {
					return [((ChatterMessage *)obj2).timestampStr compare:((ChatterMessage *)obj1).timestampStr];
				})] retain];
			}
		}
		
		// sort the messages by person (sender)
		else if (mIsSortedByPerson) {
			visibleData = [[visibleData sortedArrayUsingComparator:(^ NSComparisonResult (id obj1, id obj2) {
				ChatterAccount *account1, *account2;
				NSString *name1, *name2;
				
				account1 = ((ChatterMessage *)obj1).account;
				account2 = ((ChatterMessage *)obj2).account;
				
				name1 = account1.person.name;
				name2 = account2.person.name;
				
				if (name1 == nil)
					name1 = account1.screenname;
				
				if (name2 == nil)
					name2 = account2.screenname;
				
				return mIsSortedAscending ? [name1 compare:name2] : [name2 compare:name1];
			})] retain];
		}
		
		if (mStopRendering)
			goto done;
		
		[mTmpVisibleData release];
		mTmpVisibleData = [visibleData retain];
		
		[Easy postNotification:@"ChatterNotificationProgressTextChanged" object:@""];
		
		[self performSelectorOnMainThread:@selector(showDataSetChanges) withObject:nil waitUntilDone:FALSE];
		
		[pool2 release];
	}
	
done:
	[Easy postNotification:@"ChatterNotificationProgressTextChanged" object:@""];
	[pool release];
}

/**
 *
 *
 */
- (void)showDataSetChanges
{
	[mBubbleColorsByAccountId removeAllObjects];
	[mBubbleColorsByPersonId removeAllObjects];
	mBubbleIndex = 0;
	
	[mTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,mVisibleCount2)] withAnimation:NSTableViewAnimationSlideRight];
	
	NSArray *visibleData = [mTmpVisibleData retain];
	mTmpVisibleData = nil;
	
	[mVisibleData release];
	mVisibleData = [visibleData retain];
	mVisibleCount = [mVisibleData count];
	mVisibleCount2 = MIN(100, mVisibleCount);
	
	[visibleData release];
	
	[mTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,mVisibleCount2)] withAnimation:NSTableViewAnimationSlideLeft];
}





#pragma mark - Sort & Group Options

/**
 *
 *
 */
- (void)doActionSortOption:(id)sender
{
	NSInteger segmentIndex = [mSortOpt selectedSegment];
	
	if (segmentIndex == 0) {
		mIsSortedByDate = TRUE;
		mIsSortedByPerson = FALSE;
		mIsSortedAscending = !mIsSortedAscending;
		mIsSortedDescending = !mIsSortedDescending;
	}
	else if (segmentIndex == 1) {
		mIsSortedByDate = FALSE;
		mIsSortedByPerson = TRUE;
		mIsSortedAscending = !mIsSortedAscending;
		mIsSortedDescending = !mIsSortedDescending;
	}
	
	dispatch_semaphore_signal(mRenderSem);
}

/**
 *
 *
 */
- (void)doActionGroupOption:(id)sender
{
	NSInteger segmentIndex = [mGroupOpt selectedSegment];
	BOOL selected = [mGroupOpt isSelectedForSegment:segmentIndex];
	
	// group by chat
	if (segmentIndex == 0) {
		if (selected) {
			[mGroupOpt setSelected:FALSE forSegment:1];
			[mSortOpt setSelected:TRUE forSegment:0];
			[mSortOpt setEnabled:TRUE forSegment:0];
			[mSortOpt setEnabled:FALSE forSegment:1];
			
			mIsGroupedByChat = TRUE;
			mIsGroupedByPerson = FALSE;
			mIsSortedByDate = TRUE;
			mIsSortedByPerson = FALSE;
		}
		else {
			[mSortOpt setEnabled:TRUE forSegment:0];
			[mSortOpt setEnabled:TRUE forSegment:1];
			
			mIsGroupedByChat = FALSE;
			mIsGroupedByPerson = FALSE;
		}
	}
	
	// group by person
	else if (segmentIndex == 1) {
		if (selected) {
			[mGroupOpt setSelected:FALSE forSegment:0];
			[mSortOpt setSelected:TRUE forSegment:1];
			[mSortOpt setEnabled:FALSE forSegment:0];
			[mSortOpt setEnabled:TRUE forSegment:1];
			
			mIsGroupedByChat = FALSE;
			mIsGroupedByPerson = TRUE;
			mIsSortedByDate = FALSE;
			mIsSortedByPerson = TRUE;
		}
		else {
			[mSortOpt setEnabled:TRUE forSegment:0];
			[mSortOpt setEnabled:TRUE forSegment:1];
			
			mIsGroupedByChat = FALSE;
			mIsGroupedByPerson = FALSE;
		}
	}
	
	dispatch_semaphore_signal(mRenderSem);
}





#pragma mark - Notifications

/**
 * ChatterNotificationBuddySelectionChanged
 *
 */
- (void)doHandleBuddySelectionChanged:(NSNotification *)aNotification
{
	[mFilterAccounts release];
	mFilterAccounts = [[aNotification object] retain];
	
	dispatch_semaphore_signal(mFilterSem);
}

/**
 *
 *
 */
- (void)filterThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	ChatterObjectCache *cache = [ChatterObjectCache sharedInstance];
	
	mIsFiltered = FALSE;
	
	while (!mStopFiltering) {
		dispatch_semaphore_wait(mFilterSem, DISPATCH_TIME_FOREVER);
		
		if (mStopFiltering)
			break;
		
		NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
		
		[Easy postNotification:@"ChatterNotificationProgressTextChanged" object:@"Filtering..."];
		
		// if all or none of the accounts are selected, do not filter the messages
		if ([mFilterAccounts count] == 0 || [mFilterAccounts count] == [cache accountCount]) {
			[mFilterData release];
			mFilterData = nil;
			
			[mFilterIds release];
			mFilterIds = nil;
			
			mIsFiltered = FALSE;
		}
		
		// use the subset of messages associated with the selected accounts
		else {
			NSMutableArray *cmessages = [NSMutableArray array];
			NSMutableIndexSet *messageIds = [NSMutableIndexSet indexSet];
			NSMutableIndexSet *sessionIds = [NSMutableIndexSet indexSet];
			
			for (ChatterObject *cobject in mFilterAccounts) {
				if (mStopFiltering)
					goto done;
				
				if ([cobject isKindOfClass:[ChatterAccount class]]) {
					[ChatterSessionAccount dbobjectSelectSessionIDsForAccount:(ChatterAccount *)cobject withHandler:(^ BOOL (NSUInteger sessionId) {
						[sessionIds addIndex:sessionId];
						return !mStopFiltering;
					})];
				}
				else if ([cobject isKindOfClass:[ChatterPerson class]]) {
					[ChatterSessionAccount dbobjectSelectSessionIDsForPerson:(ChatterPerson *)cobject withHandler:(^ BOOL (NSUInteger sessionId) {
						[sessionIds addIndex:sessionId];
						return !mStopFiltering;
					})];
				}
			}
			
			[sessionIds enumerateIndexesUsingBlock:(^ (NSUInteger sessionId, BOOL *stop) {
				if (mStopFiltering)
					*stop = TRUE;
				[ChatterMessage dbobjectSelectIDsForSessionId:sessionId withHandler:(^ BOOL (NSUInteger messageId) {
					[cmessages addObject:[cache messageForId:messageId]];
					[messageIds addIndex:messageId];
					return !mStopFiltering;
				})];
			})];
			
			if (mStopFiltering)
				goto done;
			
			[mFilterData release];
			mFilterData = [cmessages retain];
			
			[mFilterIds release];
			mFilterIds = [messageIds retain];
			
			mIsFiltered = TRUE;
			
			[pool2 release];
		}
		
		[Easy postNotification:@"ChatterNotificationProgressTextChanged" object:@""];
		
		dispatch_semaphore_signal(mRenderSem);
	}
	
done:
	[Easy postNotification:@"ChatterNotificationProgressTextChanged" object:@""];
	[pool release];
}

/**
 * ChatterNotificationSearchQueryChanged
 *
 */
- (void)doHandleSearchQueryChangedNotification:(NSNotification *)notification
{
	NSString *queryString = [notification object];
	
	[mQueryString release];
	mQueryString = [queryString retain];
	
	mLastQueryChange = [NSDate timeIntervalSinceReferenceDate];
	
	if (mQueryTimer == nil)
		mQueryTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(queryChangeTimer:) userInfo:nil repeats:TRUE] retain];
}

/**
 *
 *
 */
- (void)queryChangeTimer:(NSTimer *)timer
{
	if (mLastQueryChange + 1.5 < [NSDate timeIntervalSinceReferenceDate])
		return;
	
	[timer invalidate];
	
	[mQueryTimer release];
	mQueryTimer = nil;
	
	dispatch_semaphore_signal(mSearchSem);
}

/**
 *
 *
 */
- (void)searchThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	MessageSearch *messageSearch = [[[MessageSearch alloc] init] autorelease];
	void (^searchHandler)(NSArray*, NSIndexSet*);
	
	searchHandler = ^ (NSArray *cmessages, NSIndexSet *messageIds) {
		if (mStopSearching)
			return;
		
		[mSearchData release];
		mSearchData = [cmessages retain];
		
		[mSearchIds release];
		mSearchIds = [messageIds retain];
		
		mIsSearched = TRUE;
		
		[Easy postNotification:@"ChatterNotificationProgressTextChanged" object:@""];
		
		dispatch_semaphore_signal(mRenderSem);
	};
	
	while (!mStopSearching) {
		dispatch_semaphore_wait(mSearchSem, DISPATCH_TIME_FOREVER);
		
		if (mStopSearching)
			break;
		
		NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
		
		[Easy postNotification:@"ChatterNotificationProgressTextChanged" object:@"Searching..."];
		
		// if there's a search taking place already, tell it to stop and wait for it to stop
		if (!messageSearch.isStopped) {
			[messageSearch stop];
			
			while (!messageSearch.isStopped)
				usleep(100000);
		}
		
		if ([mQueryString length] == 0) {
			[mSearchData release];
			mSearchData = nil;
			
			[mSearchIds release];
			mSearchIds = nil;
			
			mIsSearched = FALSE;
			
			[Easy postNotification:@"ChatterNotificationProgressTextChanged" object:@""];
			
			dispatch_semaphore_signal(mRenderSem);
		}
		else {
			NSString *queryString = [[mQueryString retain] autorelease];
			
			NSArray *sortedData = [[mData sortedArrayUsingComparator:(^ NSComparisonResult (id obj1, id obj2) {
				return [((ChatterMessage *)obj1).timestampStr compare:((ChatterMessage *)obj2).timestampStr];
			})] retain];
			
			[messageSearch searchData:sortedData withQuery:queryString inBackground:TRUE andHandler:searchHandler];
		}
		
		[pool2 release];
	}
	
	[pool release];
}





#pragma mark - NSTableViewDataSource

/**
 *
 *
 */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if (mVisibleCount2 == 0 && mVisibleCount != 0)
		mVisibleCount2 = MIN(100, mVisibleCount);
	else if (mVisibleCount2 > mVisibleCount)
		mVisibleCount2 = mVisibleCount;
	
	return mVisibleCount2;
}

/**
 *
 *
 */
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if (rowIndex >= 0 && rowIndex < [mVisibleData count])
		return [mVisibleData objectAtIndex:rowIndex];
	else
		return nil;
}

/**
 *
 *
 */
- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
	NSLog(@"%s..", __PRETTY_FUNCTION__);
	
}





#pragma mark - NSTableViewDelegate

/**
 *
 *
 */
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
	NSObject *object = [mVisibleData objectAtIndex:row];
	
	return [object isKindOfClass:[NSNull class]];
}

/**
 *
 *
 */
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSView *view = [self __tableView:tableView viewForTableColumn:tableColumn row:row];
	
	if (row == mVisibleCount2-1 && mVisibleCount2 != mVisibleCount)
		[self performSelector:@selector(updateVisibleRowCount) withObject:nil afterDelay:0.];
	
	return view;
}

/**
 *
 *
 */
- (NSView *)__tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if (row >= [mVisibleData count]) {
		NSLog(@"%s.. problem!", __PRETTY_FUNCTION__);
		return nil;
	}
	
	NSObject *object = [mVisibleData objectAtIndex:row];
	
	if ([object isKindOfClass:[ChatterMessage class]]) {
		ChatterMessage *cmessage = (ChatterMessage *)object;
		MessageView *view = [tableView makeViewWithIdentifier:@"MessageView" owner:self];
		CGColorRef bubbleColor = NULL;
		
		if (NULL == (bubbleColor = (CGColorRef)[mBubbleColorsByAccountId objectForKey:[NSNumber numberWithInteger:cmessage.accountId]]))
			bubbleColor = (CGColorRef)[mBubbleColorsByAccountId objectForKey:[NSNumber numberWithInteger:cmessage.account.personId]];
		
		if (view == nil) {
			view = [[[MessageView alloc] initWithFrame:NSMakeRect(0., 0., [tableView frame].size.width, 0.)] autorelease];
			view.identifier = @"MessageView";
		}
		
		// determine whether the message on this row is part of a group of messages sent by the same
		// account/person by looking at the messages on the previous and next rows. this information is
		// used to determine how to draw the messages.
		{
			BOOL isTop = TRUE;
			BOOL isBottom = TRUE;
			ChatterMessage *prevMessage=nil, *nextMessage=nil;
			ChatterPerson *cperson=nil, *nextPerson=nil, *prevPerson=nil;
			ChatterAccount *caccount=nil, *nextAccount=nil, *prevAccount=nil;
			
			if (row > 0) {
				NSObject *prevObject = [mVisibleData objectAtIndex:row - 1];
				
				if ([prevObject isKindOfClass:[ChatterMessage class]]) {
					prevMessage = (ChatterMessage *)prevObject;
					
					if (prevMessage.accountId == cmessage.accountId) {
						if (!bubbleColor)
							bubbleColor = (CGColorRef)[mBubbleColorsByAccountId objectForKey:[NSNumber numberWithInteger:cmessage.accountId]];
						isTop = FALSE;
					}
					else {
						if ((caccount = cmessage.account) && (prevAccount = prevMessage.account) == caccount) {
							if (!bubbleColor)
								bubbleColor = (CGColorRef)[mBubbleColorsByAccountId objectForKey:[NSNumber numberWithInteger:prevMessage.accountId]];
							isTop = FALSE;
						}
						else if ((cperson = caccount.person) && (prevPerson = prevAccount.person) == cperson) {
							if (!bubbleColor)
								bubbleColor = (CGColorRef)[mBubbleColorsByPersonId objectForKey:[NSNumber numberWithInteger:prevPerson.databaseId]];
							isTop = FALSE;
						}
					}
				}
			}
			
			if (row < [mVisibleData count] - 1) {
				NSObject *nextObject = [mVisibleData objectAtIndex:row + 1];
				
				if ([nextObject isKindOfClass:[ChatterMessage class]]) {
					nextMessage = (ChatterMessage *)nextObject;
					
					if (nextMessage.accountId == cmessage.accountId) {
						if (!bubbleColor)
							bubbleColor = (CGColorRef)[mBubbleColorsByAccountId objectForKey:[NSNumber numberWithInteger:cmessage.accountId]];
						isBottom = FALSE;
					}
					else {
						if ((caccount = cmessage.account) && (nextAccount = nextMessage.account) == caccount) {
							if (!bubbleColor)
								bubbleColor = (CGColorRef)[mBubbleColorsByAccountId objectForKey:[NSNumber numberWithInteger:nextMessage.accountId]];
							isBottom = FALSE;
						}
						else if ((cperson = caccount.person) && (nextPerson = nextAccount.person) == cperson) {
							if (!bubbleColor)
								bubbleColor = (CGColorRef)[mBubbleColorsByPersonId objectForKey:[NSNumber numberWithInteger:nextPerson.databaseId]];
							isBottom = FALSE;
						}
					}
				}
			}
			
			{
				if (bubbleColor == NULL)
					bubbleColor = mBubbleColors[(mBubbleIndex++ % mBubbleCount)];
				
				if (cmessage.accountId != 0)
					[mBubbleColorsByAccountId setObject:(NSObject *)bubbleColor forKey:[NSNumber numberWithInteger:cmessage.accountId]];
				
				if (cmessage.account.personId != 0)
					[mBubbleColorsByPersonId setObject:(NSObject *)bubbleColor forKey:[NSNumber numberWithInteger:cmessage.account.personId]];
			}
			
			view.tableView = tableView;
			view.tableRowIndex = row;
			view.enableViewConversation = TRUE;
			
			if (isTop && isBottom)
				view.positionType = MessageViewTypeWhole;
			else if (isTop)
				view.positionType = MessageViewTypeTop;
			else if (isBottom)
				view.positionType = MessageViewTypeBottom;
			else
				view.positionType = MessageViewTypeMiddle;
		}
		
		[view configureWithMessage:cmessage];
		[view setBubbleColor:bubbleColor];
		
		return view;
	}
	
	else if ([object isKindOfClass:[NSNull class]]) {
		ChatterMessage *cmessage = [mVisibleData objectAtIndex:row + 1];
		MessageGroupView *view = [tableView makeViewWithIdentifier:@"MessageGroupView" owner:self];
		
		if (view == nil) {
			view = [[[MessageGroupView alloc] initWithFrame:NSMakeRect(0., 0., [tableView frame].size.width, 0.)] autorelease];
			view.identifier = @"MessageGroupView";
		}
		
		view.isChatGroup = mIsGroupedByChat;
		view.isPersonGroup = mIsGroupedByPerson;
		[view configureWithMessage:cmessage];
		
		return view;
	}
	
	else
		return nil;
}

/**
 *
 *
 */
- (void)updateVisibleRowCount
{
	if (mVisibleCount2 != mVisibleCount) {
		mVisibleCount2 = MIN(mVisibleCount2+100, mVisibleCount);
		[mTableView noteNumberOfRowsChanged];
	}
}

/**
 *
 *
 */
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	if (row >= [mVisibleData count]) {
		NSLog(@"%s.. problem!", __PRETTY_FUNCTION__);
		return 0.;
	}
	
	if ([mVisibleData count] == 0)
		return 40.;
	
	NSView *view = [self __tableView:tableView viewForTableColumn:nil row:row];
	
	if (view == nil)
		return 40.;
	
	return view.frame.size.height + view.frame.origin.y;
}

@end
