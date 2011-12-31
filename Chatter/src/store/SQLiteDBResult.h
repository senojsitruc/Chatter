//
//  SQLiteDBResult.h
//  Get
//
//  Created by Curtis Jones on 2010.03.10.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBResult.h"
#import "DBStatement.h"
#import "SQLiteDBStatement.h"

@interface SQLiteDBResult : DBResult
{
	SQLiteDBStatement *mStatement;    // prepared statement object
}

/**
 *
 */
- (id)initWithStatement:(DBStatement *)statement;

/**
 *
 */
- (BOOL)next;

/**
 *
 */
- (BOOL)getString:(NSString **)value atColumn:(NSUInteger)column;

/**
 *
 */
- (BOOL)getBlob:(NSData **)value atColumn:(NSUInteger)column;

/**
 *
 */
- (BOOL)getDate:(NSDate **)value atColumn:(NSUInteger)column;

/**
 *
 */
- (BOOL)getInt32:(NSInteger *)value atColumn:(NSUInteger)column;

/**
 *
 */
- (BOOL)getUint32:(NSUInteger *)value atColumn:(NSUInteger)column;

/**
 *
 */
- (BOOL)getUint64:(uint64_t *)value atColumn:(NSUInteger)column;

/**
 *
 */
- (BOOL)getFloat:(float *)value atColumn:(NSUInteger)column;

/**
 *
 */
- (BOOL)getDouble:(double *)value atColumn:(NSUInteger)column;

@end
