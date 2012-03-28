//
//  MessageSearch.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageSearch.h"
#import "ChatterMessage.h"
#import "ChatterMessageWord+DBObject.h"
#import "ChatterWord.h"
#import "ChatterObjectCache.h"
#import "NSIndexSet+Additions.h"
#import "Stemmer.h"

@interface MessageSearch (PrivateMethods)
- (void)search;
@end





@implementation MessageSearch

@synthesize isStopped = mStopped;

/**
 *
 *
 */
- (id)init
{
	self = [super init];
	
	if (self) {
		mStop = FALSE;
		mStopped = TRUE;
	}
	
	return self;
}

/**
 *
 *
 */
- (void)stop
{
	mStop = TRUE;
}

/**
 *
 *
 */
- (void)searchData:(NSArray *)data withQuery:(NSString *)query inBackground:(BOOL)background andHandler:(void (^)(NSArray*, NSIndexSet*))handler;
{
	mStop = FALSE;
	
	mMessages = data;
	
	mQuery = query;
	
	mHandler = [handler copy];
	
	if (background)
		[NSThread detachNewThreadSelector:@selector(search) toTarget:self withObject:nil];
	else
		[self search];
}

/**
 *
 *
 */
- (void)search
{
	@autoreleasepool {
		ChatterObjectCache *cache = [ChatterObjectCache sharedInstance];
		NSIndexSet *messageIds = nil;
		NSMutableIndexSet *indexesOfHits = [NSMutableIndexSet indexSet];
		
		for (NSString *word in [Stemmer stemsForWords:mQuery]) {
			ChatterWord *cword = [cache wordForWord:word];
			NSMutableIndexSet *idsForWord = [NSMutableIndexSet indexSet];
			
			if (mStop)
				goto done;
			
			if (cword == nil)
				continue;
			
			[ChatterMessageWord dbobjectSelectMessageIdsForWord:cword withHandler:(^ BOOL (NSUInteger messageId) {
				if (mStop)
					return FALSE;
				[idsForWord addIndex:messageId];
				return !mStop;
			})];
			
			if (messageIds == nil)
				messageIds = idsForWord;
			else
				messageIds = [messageIds intersectionWithIndexes:idsForWord];
		}
		
		if (mStop)
			goto done;
		
		// find the indexes of the search results within the searched data set
		{
			NSUInteger index = 0;
			
			for (ChatterMessage *cmessage in mMessages) {
				if (mStop)
					goto done;
				
				if ([messageIds containsIndex:cmessage.databaseId])
					[indexesOfHits addIndex:index];
				
				index += 1;
			}
		}
		
		if (mStop)
			goto done;
		
		mHandler([mMessages objectsAtIndexes:indexesOfHits], messageIds);
		
done:
		mStopped = TRUE;
	}
}

@end
