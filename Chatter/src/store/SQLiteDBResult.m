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
		mStatement = (SQLiteDBStatement*)[statement retain];
	}
	
	return self;
}

/**
 *
 *
 */
- (void)dealloc
{
	[mStatement release];
	[super dealloc];
}





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
- (BOOL)getString:(NSString **)value atColumn:(NSUInteger)column
{
	const char *cstr;
	
	if (*value != nil) {
		[*value release];
		*value = nil;
	}
	
	cstr = (const char *)sqlite3_column_text(mStatement->mStmt, (int)column);
	
	if (cstr != NULL)
		*value = [[NSString alloc] initWithCString:cstr encoding:NSUTF8StringEncoding];
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)getBlob:(NSData **)value atColumn:(NSUInteger)column
{
	const void *data;
	int length;
	
	if (*value != nil) {
		[*value release];
		*value = nil;
	}
	
	data = sqlite3_column_blob(mStatement->mStmt, (int)column);
	length = sqlite3_column_bytes(mStatement->mStmt, (int)column);
	
	if (data != NULL && length != 0)
		*value = [[NSData alloc] initWithBytes:data length:length];
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)getDate:(NSDate **)value atColumn:(NSUInteger)column
{
	NSString *string = nil;
	
	if (FALSE == [self getString:&string atColumn:column])
		return FALSE;
	
	*value = [[NSDate dateWithString:string] retain];
	
	[string release];
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)getInt32:(NSInteger *)value atColumn:(NSUInteger)column
{
	*value = sqlite3_column_int(mStatement->mStmt, (int)column);
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)getUint32:(NSUInteger *)value atColumn:(NSUInteger)column
{
	*value = sqlite3_column_int(mStatement->mStmt, (int)column);
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)getUint64:(uint64_t *)value atColumn:(NSUInteger)column
{
	*value = sqlite3_column_int64(mStatement->mStmt, (int)column);
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)getFloat:(float *)value atColumn:(NSUInteger)column
{
	*value = (float)sqlite3_column_double(mStatement->mStmt, (int)column);
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)getDouble:(double *)value atColumn:(NSUInteger)column
{
	*value = sqlite3_column_double(mStatement->mStmt, (int)column);
	
	return TRUE;
}

@end
