//
//  MessageTableController.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageSearch;
@class MessageTabView;

@interface MessageTableController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
{
@private
	/* interface */
	IBOutlet NSTableView *mTableView;
	IBOutlet NSSegmentedControl *mSortOpt;
	IBOutlet NSSegmentedControl *mGroupOpt;
	IBOutlet MessageTabView *mGroupByChatTab;
	IBOutlet MessageTabView *mGroupByPersonTab;
	
	/* data */
	NSMutableArray *mData;
	NSArray *mSearchData;
	NSArray *mFilterData;
	NSArray *mVisibleData;
	NSArray *mTmpVisibleData;
	NSArray *mFilterAccounts;
	NSMutableIndexSet *mSearchIds;
	NSMutableIndexSet *mFilterIds;
	NSUInteger mVisibleCount;
	NSUInteger mVisibleCount2;
	
	/* state */
	BOOL mIsSearched;
	BOOL mIsFiltered;
	BOOL mIsGroupedByChat;
	BOOL mIsGroupedByPerson;
	BOOL mIsSortedByDate;
	BOOL mIsSortedByPerson;
	BOOL mIsSortedAscending;
	BOOL mIsSortedDescending;
	
	/* bubbles */
	CGColorRef mBubbleColors[10];
	NSUInteger mBubbleIndex;
	NSUInteger mBubbleCount;
	CGColorSpaceRef mBubbleSpace;
	NSMutableDictionary *mBubbleColorsByAccountId;
	NSMutableDictionary *mBubbleColorsByPersonId;
	
	/* searching, filtering and grouping */
	BOOL mStopRendering;
	BOOL mStopSearching;
	BOOL mStopFiltering;
	
	dispatch_semaphore_t mSearchSem;
	dispatch_semaphore_t mFilterSem;
	dispatch_semaphore_t mRenderSem;
	
	NSString *mQueryString;
	NSTimeInterval mLastQueryChange;
	NSTimer *mQueryTimer;
}

@property (readwrite, assign) IBOutlet NSTableView *tableView;

- (void)loadData;
- (void)resize;

@end
