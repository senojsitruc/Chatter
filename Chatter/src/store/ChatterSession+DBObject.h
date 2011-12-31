//
//  ChatterSession+DBObject.h
//  Chatter
//
//  Created by Jones Curtis on 2011.07.09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterSession.h"
#import "DBObject.h"

@interface ChatterSession (DBObject)

+ (BOOL)dbobjectSelectAllWithHandler:(BOOL (^)(ChatterSession*))handler;
+ (NSUInteger)dbobjectSelectCount;
- (BOOL)dbobjectInsert;
- (BOOL)dbobjectUpdate;
- (BOOL)dbobjectDelete;

@end
