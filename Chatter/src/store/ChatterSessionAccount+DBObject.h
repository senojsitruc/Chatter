//
//  ChatterSessionAccount+DBObject.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatterSessionAccount.h"
#import "DBObject.h"

@class ChatterAccount;
@class ChatterPerson;
@class ChatterSession;

@interface ChatterSessionAccount (DBObject) <DBObject>

+ (BOOL)dbobjectSelectAccountIDsForSession:(ChatterSession *)session withHandler:(BOOL (^)(NSUInteger))handler;
+ (BOOL)dbobjectSelectSessionIDsForAccount:(ChatterAccount *)account withHandler:(BOOL (^)(NSUInteger))handler;
+ (BOOL)dbobjectSelectSessionIDsForPerson:(ChatterPerson *)person withHandler:(BOOL (^)(NSUInteger))handler;
+ (BOOL)dbobjectInsertWithSession:(ChatterSession *)session andAccount:(ChatterAccount *)account;

@end
