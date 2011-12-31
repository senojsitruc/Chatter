//
//  SQLiteDBStatement.h
//  Get
//
//  Created by Curtis Jones on 2010.03.10.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBStatement.h"
#import "../extern/sqlite3/sqlite3.h"

@interface SQLiteDBStatement : DBStatement
{
@public
	sqlite3_stmt *mStmt;              // sqlite3 statement object
}

/**
 *
 */
+ (SQLiteDBStatement *)statementWithQuery:(NSString *)query andName:(NSString *)name;

/**
 *
 */
+ (SQLiteDBStatement *)statementWithSqlFile:(NSString *)sqlfile andName:(NSString *)name;

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
- (BOOL)bindInt32:(NSInteger)number atIndex:(NSUInteger)index;

/**
 *
 */
- (BOOL)bindUint32:(NSUInteger)number atIndex:(NSUInteger)index;

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
