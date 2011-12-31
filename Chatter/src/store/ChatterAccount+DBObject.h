//
//  ChatterAccount+DBObject.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatterAccount.h"
#import "DBObject.h"

@interface ChatterAccount (DBObject) <DBObject>

+ (BOOL)dbobjectSelectAllWithHandler:(BOOL (^)(ChatterAccount*))handler;
+ (NSUInteger)dbobjectSelectCount;

@end
