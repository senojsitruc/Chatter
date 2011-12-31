//
//  ChatterSource+DBObject.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatterSource.h"
#import "DBObject.h"

@interface ChatterSource (DBObject) <DBObject>

+ (BOOL)dbobjectSelectAllWithHandler:(BOOL (^)(ChatterSource*))handler;
+ (NSUInteger)dbobjectSelectCount;

@end
