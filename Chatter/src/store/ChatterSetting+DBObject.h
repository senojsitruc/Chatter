//
//  ChatterSetting+DBObject.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterSetting.h"
#import "ChatterSetting.h"
#import "DBObject.h"

@interface ChatterSetting (DBObject) <DBObject>

+ (BOOL)dbobjectDeleteForName:(NSString *)name andValue:(NSString *)value;
+ (BOOL)dbobjectInsertSettingWithName:(NSString *)name andValue:(NSString *)value;
+ (BOOL)dbobjectSelectAllForName:(NSString *)name withHandler:(BOOL (^)(ChatterSetting*))handler;
+ (BOOL)dbobjectSelectAllWithHandler:(BOOL (^)(ChatterSetting*))handler;
+ (NSUInteger)dbobjectSelectCount;

@end
