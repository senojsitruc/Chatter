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
- (NSString *)getStringAtColumn:(NSUInteger)column;

/**
 *
 */
- (NSData *)getBlobAtColumn:(NSUInteger)column;

/**
 *
 */
- (NSDate *)getDateAtColumn:(NSUInteger)column;

/**
 *
 */
- (NSInteger)getInt32AtColumn:(NSUInteger)column;

/**
 *
 */
- (NSUInteger)getUint32AtColumn:(NSUInteger)column;

/**
 *
 */
- (uint64_t)getUint64AtColumn:(NSUInteger)column;

/**
 *
 */
- (float)getFloatAtColumn:(NSUInteger)column;

/**
 *
 */
- (double)getDoubleAtColumn:(NSUInteger)column;

@end
