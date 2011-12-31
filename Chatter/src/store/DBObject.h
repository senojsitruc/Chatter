//
//  DBObject.h
//  Get
//
//  Created by Curtis Jones on 2010.03.11.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define DBOBJ_ERROR(s,r,d) {                                              \
  NSLog(@"%s.. [%@] failed to exec", __PRETTY_FUNCTION__, (s)->mName);    \
  [(s) dump];                                                             \
  r = FALSE;                                                              \
  goto d;                                                                 \
}

#define DBOBJ_HANDLE(constructor) {                                       \
  while (![result isDone]) {                                              \
    object = constructor;                                                 \
    [object __dbobjectHandleResult:result];                               \
    [objects addObject:object];                                           \
    [result next];                                                        \
  }                                                                       \
}

#define DBOBJ_HANDLE2(constructor, handler) {                             \
  while (![result isDone]) {                                              \
    object = constructor;                                                 \
    [object __dbobjectHandleResult:result];                               \
    if (FALSE == handler(object))                                         \
      break;                                                              \
    [result next];                                                        \
  }                                                                       \
}

extern NSString * const ChatterExceptionNoDbConnection;
extern NSString * const ChatterExceptionNoStatement;
extern NSString * const ChatterExceptionDbAlreadyConnected;
extern NSString * const ChatterExceptionIllegalOperation;

typedef enum
{
	DBObjectComparisonEquals = 1,
	DBObjectComparisonNotEquals = 2
} DBObjectComparisonResult;





@protocol DBObject

/**
 *
 */
//- (id<DBObject>)dbobjectCopy;

/**
 *
 */
- (BOOL)dbobjectInsert;

/**
 *
 */
- (BOOL)dbobjectUpdate;

/**
 *
 */
- (BOOL)dbobjectDelete;

@end





@interface DBObject : NSObject

@end
