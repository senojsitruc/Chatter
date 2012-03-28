//
//  SQLiteDBResult.m
//  Get
//
//  Created by Curtis Jones on 2010.03.10.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import "SQLiteDBResult.h"

@implementation SQLiteDBResult

#pragma mark - Structors

/**
 *
 *
 */
- (id)initWithStatement:(DBStatement *)statement
{
	self = [super init];
	
	if (self) {
		mIsDone = FALSE;
		mStatement = (SQLiteDBStatement*)statement;
	}
	
	return self;
}

/**
 *
 *
 */





#pragma mark - DBResult

/**
 *
 *
 */
- (BOOL)next
{
	int error;
	
	if (mIsDone)
		return FALSE;
	
	error = sqlite3_step(mStatement->mStmt);
	
	if (SQLITE_ERROR == error) {
		//NSLog(@"%s.. failed to sqlite3_step, %d", __PRETTY_FUNCTION__, error);
		return FALSE;
	}
	
	else if (SQLITE_DONE == error) {
		mIsDone = TRUE;
		[mStatement clear];
		return TRUE;
	}
	
	else if (SQLITE_ROW == error)
		return TRUE;
	
	else {
		//NSLog(@"%s.. sqlite3_step() = %d", __PRETTY_FUNCTION__, error);
		return FALSE;
	}
}

/**
 *
 *
 */
- (NSString *)getStringAtColumn:(NSUInteger)column
{
	NSString *value = nil;
	const char *cstr;
	
	cstr = (const char *)sqlite3_column_text(mStatement->mStmt, (int)column);
	
	if (cstr != NULL)
		value = [[NSString alloc] initWithCString:cstr encoding:NSUTF8StringEncoding];
	
	return value;
}

/**
 *
 *
 */
- (NSData *)getBlobAtColumn:(NSUInteger)column
{
	NSData *value = nil;
	const void *data;
	int length;
	
	data = sqlite3_column_blob(mStatement->mStmt, (int)column);
	length = sqlite3_column_bytes(mStatement->mStmt, (int)column);
	
	if (data != NULL && length != 0)
		value = [[NSData alloc] initWithBytes:data length:length];
	
	return value;
}

/**
 *
 *
 */
- (NSDate *)getDateAtColumn:(NSUInteger)column
{
	NSDate *value = nil;
	NSString *string = nil;
	
	string = [self getStringAtColumn:column];
	
	if (string)
		value = [NSDate dateWithString:string];
	
	return value;
}

/**
 *
 *
 */
- (NSInteger)getInt32AtColumn:(NSUInteger)column
{
	return sqlite3_column_int(mStatement->mStmt, (int)column);
}

/**
 *
 *
 */
- (NSUInteger)getUint32AtColumn:(NSUInteger)column
{
	return sqlite3_column_int(mStatement->mStmt, (int)column);
}

/**
 *
 *
 */
- (uint64_t)getUint64AtColumn:(NSUInteger)column
{
	return sqlite3_column_int64(mStatement->mStmt, (int)column);
}

/**
 *
 *
 */
- (float)getFloatAtColumn:(NSUInteger)column
{
	return (float)sqlite3_column_double(mStatement->mStmt, (int)column);
}

/**
 *
 *
 */
- (double)getDoubleAtColumn:(NSUInteger)column
{
	return sqlite3_column_double(mStatement->mStmt, (int)column);
}

@end
