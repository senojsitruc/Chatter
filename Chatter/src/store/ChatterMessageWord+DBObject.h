//
//  ChatterMessageWord+DBObject.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterMessageWord.h"
#import "DBObject.h"

@class ChatterMessage;
@class ChatterWord;

@interface ChatterMessageWord (DBObject) <DBObject>

+ (BOOL)dbobjectInsertWithMessage:(ChatterMessage *)message andWord:(ChatterWord *)word;
+ (BOOL)dbobjectSelectMessageIdsForWord:(ChatterWord *)word withHandler:(BOOL (^)(NSUInteger))handler;

@end
