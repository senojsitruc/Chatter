//
//  ChatterMessage+DBObject.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatterMessage.h"
#import "DBObject.h"

@class ChatterAccount;
@class ChatterPerson;

@interface ChatterMessage (DBObject) <DBObject>

+ (NSUInteger)dbobjectSelectIdForTimestamp:(NSString *)timestamp sessionId:(NSUInteger)sessionId screenName:(NSString *)screenName message:(NSString *)message;
+ (BOOL)dbobjectDeleteForSessionId:(NSUInteger)sessionId;
+ (NSUInteger)dbobjectSelectCountForSessionId:(NSUInteger)sessionId;
+ (BOOL)dbobjectDeleteForAccount:(ChatterAccount *)account;
+ (BOOL)dbobjectDeleteForPerson:(ChatterPerson *)person;
+ (NSArray *)dbobjectSelectAllWithHandler:(BOOL (^)(ChatterMessage*))handler;
+ (BOOL)dbobjectSelectIDsForAccount:(ChatterAccount *)account withHandler:(BOOL (^) (NSUInteger))handler;
+ (BOOL)dbobjectSelectIDsForPerson:(ChatterPerson *)person withHandler:(BOOL (^) (NSUInteger))handler;
+ (BOOL)dbobjectSelectIDsForSessionId:(NSUInteger)sessionId withHandler:(BOOL (^) (NSUInteger))handler;
+ (NSUInteger)dbobjectSelectCount;

@end
