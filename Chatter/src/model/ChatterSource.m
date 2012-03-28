//
//  ChatterSource.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterSource.h"
#import "ChatterObjectCache.h"

@implementation ChatterSource

@synthesize service = mService;
@dynamic filePath;
@dynamic timestamp;
@dynamic aliasHandle;
@synthesize timestampStr = mTimestampStr;





#pragma mark - Structors

/**
 *
 *
 */
+ (id)source
{
	return [[[self class] alloc] init];
}





#pragma mark - Accessors

/**
 *
 *
 */
- (NSString *)filePath
{
	return mFilePath;
}

/**
 *
 *
 */
- (void)setFilePath:(NSString *)filePath
{
	OSErr error;
	
	AliasHandle mAliasHandle;
	
	if (mFilePath == filePath || [mFilePath isEqualToString:filePath])
		return;
	
	mFilePath = filePath;
	
	if (noErr != (error = FSNewAliasFromPath(NULL, [filePath cStringUsingEncoding:NSUTF8StringEncoding], 0, &mAliasHandle, NULL))) {
		NSLog(@"%s.. failed to FSNewAliasFromPath(%@), %d", __PRETTY_FUNCTION__, filePath, error);
		return;
	}
	
	
}

/**
 *
 *
 */
- (AliasHandle)aliasHandle
{
	
	return NULL;
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

@end
