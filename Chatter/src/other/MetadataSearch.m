//
//  MetadataSearch.m
//  Chatter
//
//  Created by Jones Curtis on 2011.07.07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MetadataSearch.h"

@implementation MetadataSearch

@synthesize isDone = mIsDone;
@synthesize contentType = mContentType;
@synthesize typeCode = mTypeCode;
@synthesize kind = mKind;
@synthesize name = mName;
@dynamic handler;





#pragma mark - Structors

/**
 *
 *
 */
+ (id)searchByContentType:(NSString *)contentType andTypeCode:(NSString *)typeCode andKind:(NSString *)kind andName:(NSString *)name withHandler:(MetadataSearchHandler)handler
{
	MetadataSearch *search = [[[MetadataSearch alloc] init] autorelease];
	
	search.contentType = contentType;
	search.typeCode = typeCode;
	search.kind = kind;
	search.name = name;
	search.handler = [[handler copy] autorelease];
	
	[NSThread detachNewThreadSelector:@selector(start:) toTarget:search withObject:search];
	//[search performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:FALSE];
	
	return search;
}

/**
 *
 *
 */
- (id)init
{
	self = [super init];
	
	if (self) {
		// ...
	}
	
	return self;
}

/**
 *
 *
 */
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[mQuery release];
	[mPredicate release];
	
	[mContentType release];
	[mTypeCode release];
	[mKind release];
	[mName release];
	
	[mHandler release];
	
	[super dealloc];
}





#pragma mark - Accessors

/**
 *
 *
 */
- (void)start:(MetadataSearch *)search
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *predicates = [NSMutableArray array];
	
	mIsDone = FALSE;
	
	if (mContentType)
		[predicates addObject:[NSPredicate predicateWithFormat:@"%K == %@", kMDItemContentType, mContentType, nil]];
	
	if (mTypeCode)
		[predicates addObject:[NSPredicate predicateWithFormat:@"%K == %@", @"kMDItemFSTypeCode", mTypeCode, nil]];
	
	if (mKind)
		[predicates addObject:[NSPredicate predicateWithFormat:@"%K == %@", kMDItemKind, mKind, nil]];
	
	if (mName)
		[predicates addObject:[NSPredicate predicateWithFormat:@"%K == %@", kMDItemFSName, mName, nil]];
	
	mQuery = [[NSMetadataQuery alloc] init];
	
	if ([predicates count] == 1)
		mPredicate = [[predicates objectAtIndex:0] retain];
	else
		mPredicate = [[NSCompoundPredicate orPredicateWithSubpredicates:predicates] retain];
	
	NSLog(@"%@", mPredicate);
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doHandleNotification:) name:nil object:mQuery];
	
	[mQuery setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryLocalComputerScope]];
	[mQuery setPredicate:mPredicate];
	[mQuery setNotificationBatchingInterval:1.0];
	
	@try {
		if (FALSE == [mQuery startQuery]) {
			NSLog(@"%s.. failed to startQuery() for %@", __PRETTY_FUNCTION__, mPredicate);
			return;
		}
	}
	@catch (NSException *exception) {
		NSLog(@"%s.. failed to startQuery(), %@", __PRETTY_FUNCTION__, exception);
	}
	
	CFRunLoopRun();
	
	mIsDone = TRUE;
	
	[mPredicate release];
	mPredicate = nil;
	
	@try {
		[mQuery release];
	}
	@catch (NSException *exception) {
		NSLog(@"%s.. failed to release the query, %@", __PRETTY_FUNCTION__, exception);
	}
	
	mQuery = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[pool release];
}

/**
 *
 *
 */
- (void)stop
{
	[mQuery stopQuery];
}

/**
 *
 *
 */
- (MetadataSearchHandler)handler
{
	return mHandler;
}

/**
 *
 *
 */
- (void)setHandler:(MetadataSearchHandler)handler
{
	[mHandler release];
	mHandler = [handler retain];
}

/**
 *
 *
 */
- (void)doHandleNotification:(NSNotification *)notification
{
	NSString *name = [notification name];
	BOOL stop = FALSE;
	
	// the search has started; don't do anything
	if ([name isEqualToString:NSMetadataQueryDidStartGatheringNotification])
		;
	
	// the search has finished or was updated; process the results
	else if ([name isEqualToString:NSMetadataQueryDidFinishGatheringNotification] || [name isEqualToString:NSMetadataQueryDidUpdateNotification]) {
		CFRunLoopStop(CFRunLoopGetCurrent());
		
		/*
		mIsDone = TRUE;
		
		[mPredicate release];
		mPredicate = nil;
		
		[mQuery release];
		mQuery = nil;
		*/
	}
	
	// the search is working; don't do anything
	else if ([name isEqualToString:NSMetadataQueryGatheringProgressNotification]) {
		NSMetadataQuery *query = (NSMetadataQuery *)[notification object];
		
		if (![query isKindOfClass:[NSMetadataQuery class]])
			NSLog(@"Unexpected object type: %@ | %@", NSStringFromClass([query class]), query);
		
		[query disableUpdates];
		mHandler([query results], &stop);
		
		if (!stop)
			[query enableUpdates];
		else
			[query stopQuery];
	}
	
	// some unknown notification state
	else
		NSLog(@"%s.. [%@]", __PRETTY_FUNCTION__, name);
}

@end
