//
//  ChatterSession.m
//  Chatter
//
//  Created by Jones Curtis on 2011.07.09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterSession.h"
#import "ChatterObjectCache.h"
#import "ChatterSource.h"
#import "Easy.h"

@implementation ChatterSession

@synthesize sourceId = mSourceId;
@synthesize name = mName;
@dynamic timestamp;
@dynamic timestampStr;
@synthesize source = mSource;





#pragma mark - Structors

/**
 *
 *
 */
+ (id)session
{
	return [[self alloc] init];
}





#pragma mark - Accessors

/**
 *
 *
 */
- (ChatterSource *)source
{
	if (mSource != nil)
		return mSource;
	else if (mSourceId != 0)
		return (mSource = [[ChatterObjectCache sharedInstance] sourceForId:mSourceId]);
	else
		return nil;
}

/**
 *
 *
 */
- (void)setSource:(ChatterSource *)source
{
	if (mSource == source)
		return;
	
	mSource = source;
	mSourceId = source.databaseId;
}

/**
 *
 *
 */
- (NSDate *)timestamp
{
	if (mTimestamp != nil)
		return mTimestamp;
	else if (mTimestampStr != nil)
		return (mTimestamp = [[NSDate alloc] initWithString:mTimestampStr]);
	else
		return nil;
}

/**
 *
 *
 */
- (void)setTimestamp:(NSDate *)timestamp
{
	if (mTimestamp == timestamp)
		return;
	
	mTimestamp = timestamp;
	mTimestampStr = nil;
}

/**
 *
 *
 */
- (NSString *)timestampStr
{
	if (mTimestampStr != nil)
		return mTimestampStr;
	else if (mTimestamp != nil)
		return (mTimestampStr = [mTimestamp description]);
	else
		return nil;
}

/**
 *
 *
 */
- (void)setTimestampStr:(NSString *)timestamp
{
	if (mTimestampStr == timestamp)
		return;
	
	mTimestamp = nil;
	mTimestampStr = timestamp;
}

@end
