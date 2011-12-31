//
//  ChatterObjectCache.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChatterObject;
@class ChatterAccount;
@class ChatterMessage;
@class ChatterPerson;
@class ChatterSession;
@class ChatterSetting;
@class ChatterSource;
@class ChatterWord;

@interface ChatterObjectCache : NSObject
{
@private
	NSMutableDictionary *mAccountsById;
	NSMutableDictionary *mAccountsByName;
	NSMutableDictionary *mMessagesById;
	NSMutableDictionary *mPersonsById;
	NSMutableDictionary *mSessionsById;
	NSMutableDictionary *mSessionsByName;
	NSMutableDictionary *mSettingsById;
	NSMutableDictionary *mSettingsByName;
	NSMutableDictionary *mSourcesById;
	NSMutableDictionary *mSourcesByPath;
	NSMutableDictionary *mWordsById;
	NSMutableDictionary *mWordsByWord;
}

+ (id)sharedInstance;

- (void)addObject:(ChatterObject *)object;
- (void)removeObject:(ChatterObject *)object;

- (ChatterAccount *)accountForId:(NSUInteger)accountId;
- (ChatterAccount *)accountForName:(NSString *)screenname;
- (ChatterMessage *)messageForId:(NSUInteger)messageId;
- (ChatterPerson *)personForId:(NSUInteger)personId;
- (ChatterSession *)sessionForId:(NSUInteger)sessionId;
- (ChatterSession *)sessionForName:(NSString *)name;
- (ChatterSetting *)settingForId:(NSUInteger)settingId;
- (ChatterSetting *)settingForName:(NSString *)name;
- (ChatterSource *)sourceForId:(NSUInteger)sourceId;
- (ChatterSource *)sourceForPath:(NSString *)filePath;
- (ChatterWord *)wordForId:(NSUInteger)wordId;
- (ChatterWord *)wordForWord:(NSString *)word;

- (NSUInteger)accountCount;
- (NSUInteger)messageCount;
- (NSUInteger)personCount;
- (NSUInteger)sessionCount;
- (NSUInteger)settingCount;
- (NSUInteger)sourceCount;
- (NSUInteger)wordCount;

- (NSArray *)allAccounts;
- (NSArray *)allMessages;
- (NSArray *)allPersons;

@end
