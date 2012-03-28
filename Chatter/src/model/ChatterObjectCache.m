//
//  ChatterObjectCache.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterObjectCache.h"
#import "ChatterObject.h"
#import "ChatterAccount.h"
#import "ChatterMessage.h"
#import "ChatterPerson.h"
#import "ChatterSession.h"
#import "ChatterSetting.h"
#import "ChatterSource.h"
#import "ChatterWord.h"

static ChatterObjectCache *gObjectCache;

@implementation ChatterObjectCache





#pragma mark - Structors

/**
 *
 *
 */
+ (void)initialize
{
	gObjectCache = [[[self class] alloc] init];
}

/**
 *
 *
 */
+ (id)sharedInstance
{
	return gObjectCache;
}

/**
 *
 *
 */
- (id)init
{
	self = [super init];
	
	if (self) {
		mAccountsById = [[NSMutableDictionary alloc] init];
		mAccountsByName = [[NSMutableDictionary alloc] init];
		mMessagesById = [[NSMutableDictionary alloc] init];
		mPersonsById = [[NSMutableDictionary alloc] init];
		mSessionsById = [[NSMutableDictionary alloc] init];
		mSessionsByName = [[NSMutableDictionary alloc] init];
		mSettingsById = [[NSMutableDictionary alloc] init];
		mSettingsByName = [[NSMutableDictionary alloc] init];
		mSourcesById = [[NSMutableDictionary alloc] init];
		mSourcesByPath = [[NSMutableDictionary alloc] init];
		mWordsById = [[NSMutableDictionary alloc] init];
		mWordsByWord = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}





#pragma mark - Accessors

/**
 *
 *
 */
- (void)addObject:(ChatterObject *)object
{
	NSMutableDictionary *objectsById;
	NSUInteger objectId;
	
	if ([object isKindOfClass:[ChatterAccount class]]) {
		objectsById = mAccountsById;
		[mAccountsByName setObject:object forKey:((ChatterAccount *)object).screenname];
	}
	else if ([object isKindOfClass:[ChatterMessage class]])
		objectsById = mMessagesById;
	else if ([object isKindOfClass:[ChatterPerson class]])
		objectsById = mPersonsById;
	else if ([object isKindOfClass:[ChatterSession class]]) {
		objectsById = mSessionsById;
		[mSessionsByName setObject:object forKey:((ChatterSession *)object).name];
	}
	else if ([object isKindOfClass:[ChatterSetting class]]) {
		objectsById = mSettingsById;
		[mSettingsByName setObject:object forKey:((ChatterSetting *)object).name];
	}
	else if ([object isKindOfClass:[ChatterSource class]]) {
		objectsById = mSourcesById;
		[mSourcesByPath setObject:object forKey:((ChatterSource *)object).filePath];
	}
	else if ([object isKindOfClass:[ChatterWord class]]) {
		objectsById = mWordsById;
		[mWordsByWord setObject:object forKey:((ChatterWord *)object).word];
	}
	else
		return;
	
	if (object.databaseId != 0)
		objectId = object.databaseId;
	else
		objectId = object.objectId;
	
	@synchronized (objectsById) {
		[objectsById setObject:object forKey:[ChatterObject objectWithDatabaseId:objectId]];
	}
}

/**
 *
 *
 */
- (void)removeObject:(ChatterObject *)object
{
	NSMutableDictionary *objectsById;
	NSUInteger objectId;
	
	if ([object isKindOfClass:[ChatterAccount class]]) {
		objectsById = mAccountsById;
		[mAccountsByName removeObjectForKey:((ChatterAccount *)object).screenname];
	}
	else if ([object isKindOfClass:[ChatterMessage class]])
		objectsById = mMessagesById;
	else if ([object isKindOfClass:[ChatterPerson class]])
		objectsById = mPersonsById;
	else if ([object isKindOfClass:[ChatterSession class]]) {
		objectsById = mSessionsById;
		[mSessionsByName removeObjectForKey:((ChatterSession *)object).name];
	}
	else if ([object isKindOfClass:[ChatterSetting class]]) {
		objectsById = mSettingsById;
		[mSettingsByName removeObjectForKey:((ChatterSetting *)object).name];
	}
	else if ([object isKindOfClass:[ChatterSource class]]) {
		objectsById = mSourcesById;
		[mSourcesByPath removeObjectForKey:((ChatterSource *)object).filePath];
	}
	else if ([object isKindOfClass:[ChatterWord class]]) {
		objectsById = mWordsById;
		[mWordsByWord removeObjectForKey:((ChatterWord *)object).word];
	}
	else
		return;
	
	if (object.databaseId != 0)
		objectId = object.databaseId;
	else
		objectId = object.objectId;
	
	@synchronized (objectsById) {
		[objectsById removeObjectForKey:[ChatterObject objectWithDatabaseId:objectId]];
	}
}





#pragma mark - Accounts

/**
 *
 *
 */
- (ChatterAccount *)accountForId:(NSUInteger)accountId
{
	return [mAccountsById objectForKey:[ChatterObject objectWithObjectId:accountId]];
}

/**
 *
 *
 */
- (ChatterAccount *)accountForName:(NSString *)screenname
{
	return [mAccountsByName objectForKey:screenname];
}





#pragma mark - Messages

/**
 *
 *
 */
- (ChatterMessage *)messageForId:(NSUInteger)messageId
{
	return [mMessagesById objectForKey:[ChatterObject objectWithObjectId:messageId]];
}





#pragma mark - Persons

/**
 *
 *
 */
- (ChatterPerson *)personForId:(NSUInteger)personId
{
	return [mPersonsById objectForKey:[ChatterObject objectWithObjectId:personId]];
}





#pragma mark - Sessions

/**
 *
 *
 */
- (ChatterSession *)sessionForId:(NSUInteger)sessionId
{
	return [mSessionsById objectForKey:[ChatterObject objectWithObjectId:sessionId]];
}

/**
 *
 *
 */
- (ChatterSession *)sessionForName:(NSString *)name
{
	return [mSessionsByName objectForKey:name];
}





#pragma mark - Settings

/**
 *
 *
 */
- (ChatterSetting *)settingForId:(NSUInteger)settingId
{
	return [mSettingsById objectForKey:[ChatterObject objectWithObjectId:settingId]];
}

/**
 *
 *
 */
- (ChatterSetting *)settingForName:(NSString *)name
{
	return [mSettingsByName objectForKey:name];
}





#pragma mark - Sources

/**
 *
 *
 */
- (ChatterSource *)sourceForId:(NSUInteger)sourceId
{
	return [mSourcesById objectForKey:[ChatterObject objectWithObjectId:sourceId]];
}

/**
 *
 *
 */
- (ChatterSource *)sourceForPath:(NSString *)filePath
{
	return [mSourcesByPath objectForKey:filePath];
}





#pragma mark - Words

/**
 *
 *
 */
- (ChatterWord *)wordForId:(NSUInteger)wordId
{
	return [mWordsById objectForKey:[ChatterObject objectWithObjectId:wordId]];
}

/**
 *
 *
 */
- (ChatterWord *)wordForWord:(NSString *)word
{
	return [mWordsByWord objectForKey:word];
}





#pragma mark - Counts

/**
 *
 *
 */
- (NSUInteger)accountCount
{
	return [mAccountsById count];
}

/**
 *
 *
 */
- (NSUInteger)messageCount
{
	return [mMessagesById count];
}

/**
 *
 *
 */
- (NSUInteger)personCount
{
	return [mPersonsById count];
}

/**
 *
 *
 */
- (NSUInteger)sessionCount
{
	return [mSessionsById count];
}

/**
 *
 *
 */
- (NSUInteger)settingCount
{
	return [mSettingsById count];
}

/**
 *
 *
 */
- (NSUInteger)sourceCount
{
	return [mSourcesById count];
}

/**
 *
 *
 */
- (NSUInteger)wordCount
{
	return [mWordsById count];
}





#pragma mark - Data

/**
 *
 *
 */
- (NSArray *)allAccounts
{
	return [mAccountsById allValues];
}

/**
 *
 *
 */
- (NSArray *)allMessages
{
	return [mMessagesById allValues];
}

/**
 *
 *
 */
- (NSArray *)allPersons
{
	return [mPersonsById allValues];
}

@end
