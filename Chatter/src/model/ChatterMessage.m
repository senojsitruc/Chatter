//
//  ChatterMessage.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterMessage.h"
#import "ChatterAccount.h"
#import "ChatterSession.h"
#import "ChatterSource.h"
#import "ChatterObjectCache.h"
#import "NSString+Additions.h"

@implementation ChatterMessage

@synthesize accountId = mAccountId;
@synthesize sourceId = mSourceId;
@synthesize sessionId = mSessionId;
@synthesize screenname = mScreenName;
@dynamic timestamp;
@dynamic timestampStr;
@synthesize renderWidth = mRenderWidth;
@synthesize renderHeight = mRenderHeight;
@synthesize message = mMessage;
@dynamic account;
@dynamic source;
@dynamic session;
@synthesize sessionName = mSessionName;





#pragma mark - Structors

/**
 *
 *
 */
+ (id)message
{
	return [[[[self class] alloc] init] autorelease];
}

/**
 *
 *
 */
- (void)dealloc
{
	self.screenname = nil;
	self.timestamp = nil;
	self.timestampStr = nil;
	self.message = nil;
	self.sessionName = nil;
	
	[super dealloc];
}

/**
 *
 *
 */
- (NSString *)description
{
	return [NSString stringWithFormat:@"%@::<%p>{ screenname=%@, timestamp=%@, message=%@ }",
					NSStringFromClass([self class]), self, mScreenName, mTimestamp, [mMessage loggable]];
}





#pragma mark - Accessors

/**
 *
 *
 */
- (ChatterAccount *)account
{
	if (mAccount != nil)
		return mAccount;
	else if (mAccountId != 0)
		return (mAccount = [[ChatterObjectCache sharedInstance] accountForId:mAccountId]);
	else
		return nil;
}

/**
 *
 *
 */
- (void)setAccount:(ChatterAccount *)account
{
	if (mAccount == account)
		return;
	
	mAccount = account;
	mAccountId = account.databaseId;
}

/**
 *
 *
 */
- (ChatterSession *)session
{
	if (mSession != nil)
		return mSession;
	else if (mSessionId != 0)
		return (mSession = [[ChatterObjectCache sharedInstance] sessionForId:mSessionId]);
	else
		return nil;
}

/**
 *
 *
 */
- (void)setSession:(ChatterSession *)session
{
	if (mSession == session)
		return;
	
	mSession = session;
	mSessionId = session.databaseId;
}

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
	
	[mTimestamp release];
	mTimestamp = [timestamp retain];
	
	[mTimestampStr release];
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
		return (mTimestampStr = [[mTimestamp description] retain]);
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
	
	[mTimestamp release];
	mTimestamp = nil;
	
	[mTimestampStr release];
	mTimestampStr = [timestamp retain];
}

@end
