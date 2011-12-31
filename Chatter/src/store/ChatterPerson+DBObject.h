//
//  ChatterPerson+DBObject.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterPerson.h"
#import "DBObject.h"

@interface ChatterPerson (DBObject) <DBObject>

+ (BOOL)dbobjectSelectAllWithHandler:(BOOL (^)(ChatterPerson*))handler;
+ (ChatterPerson *)dbobjectSelectByFirstName:(NSString *)firstName andLastName:(NSString *)lastName;
+ (NSUInteger)dbobjectSelectIdByAddressBookUid:(NSString *)addressBookUid;
+ (NSUInteger)dbobjectSelectCount;

@end
