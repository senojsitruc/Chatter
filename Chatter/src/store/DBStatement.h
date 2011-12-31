//
//  DBStatement.h
//  Get
//
//  Created by Curtis Jones on 2010.03.10.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DBStatement : NSObject
{
@public
	NSString *mQuery;                 // sql query
	NSString *mName;                  // statement name
	NSMutableArray *mValues;          // persistent objects
}

@property (readonly) NSString *query;
@property (readonly) NSString *name;

/**
 *
 */
- (id)initWithQuery:(NSString *)query andName:(NSString *)name;

/**
 *
 */
- (id)initWithSqlFile:(NSString *)sqlfile andName:(NSString *)name;

/**
 *
 */
- (BOOL)clear;

/**
 *
 */
- (void)dump;

/**
 *
 */
- (BOOL)bindString:(NSString *)string atIndex:(NSUInteger)index;

/**
 *
 */
- (BOOL)bindBlob:(NSData *)data atIndex:(NSUInteger)index;

/**
 *
 */
- (BOOL)bindDate:(NSDate *)date atIndex:(NSUInteger)index;

/**
 *
 */
- (BOOL)bindUint8:(NSUInteger)number atIndex:(NSUInteger)index;

/**
 *
 */
- (BOOL)bindUint32:(NSUInteger)number atIndex:(NSUInteger)index;

/**
 *
 */
- (BOOL)bindInt32:(NSInteger)number atIndex:(NSUInteger)index;

/**
 *
 */
- (BOOL)bindUint64:(uint64_t)number atIndex:(NSUInteger)index;

/**
 *
 */
- (BOOL)bindFloat:(float)number atIndex:(NSUInteger)index;

/**
 *
 */
- (BOOL)bindDouble:(double)number atIndex:(NSUInteger)index;

/**
 *
 */
- (BOOL)bindNullAtIndex:(NSUInteger)index;

@end
