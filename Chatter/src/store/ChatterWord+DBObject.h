//
//  ChatterWord+DBObject.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatterWord.h"
#import "DBObject.h"

@interface ChatterWord (DBObject) <DBObject>

+ (BOOL)dbobjectSelectAllWithHandler:(BOOL (^)(ChatterWord*))handler;
+ (NSUInteger)dbobjectSelectCount;

@end
