//
//  SQLiteDBStatement.m
//  Get
//
//  Created by Curtis Jones on 2010.03.10.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import "SQLiteDBStatement.h"
#import <stdint.h>

@implementation SQLiteDBStatement

#pragma mark - Structors

/**
 *
 *
 */
+ (SQLiteDBStatement *)statementWithQuery:(NSString *)query andName:(NSString *)name
{
	return [[[SQLiteDBStatement alloc] initWithQuery:query andName:name] autorelease];
}

/**
 *
 *
 */
+ (SQLiteDBStatement *)statementWithSqlFile:(NSString *)sqlfile andName:(NSString *)name
{
	return [[[SQLiteDBStatement alloc] initWithSqlFile:sqlfile andName:name] autorelease];
}

/**
 *
 *
 */
- (id)initWithQuery:(NSString *)query andName:(NSString *)name
{
	self = [super initWithQuery:query andName:name];
	
	if (self) {
		// ...
	}
	
	return self;
}

/**
 *
 *
 */
- (id)initWithSqlFile:(NSString *)sqlfile andName:(NSString *)name
{
	self = [super initWithSqlFile:sqlfile andName:name];
	
	if (self) {
		// ...
	}
	
	return self;
}

/**
 *
 *
 */
- (void)dealloc
{
	if (mStmt != NULL) {
		sqlite3_finalize(mStmt);
		mStmt = NULL;
	}
	
	[super dealloc];
}





#pragma mark - DBStatement

/**
 *
 *
 */
- (BOOL)clear
{
	int error;
	
	error = sqlite3_clear_bindings(mStmt);
	
	if (SQLITE_OK != error) {
		//NSLog(@"%s.. [%@] failed to sqlite3_clear_bindings, %d", __PRETTY_FUNCTION__, mName, error);
		return FALSE;
	}
	
	error = sqlite3_reset(mStmt);
	
	if (SQLITE_OK != error) {
		//NSLog(@"%s.. [%@] failed to sqlite3_reset, %d", __PRETTY_FUNCTION__, mName, error);
		return FALSE;
	}
	
	[mValues removeAllObjects];
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)bindString:(NSString *)_string atIndex:(NSUInteger)index
{
	int error;
	
	if (_string == nil)
		return [self bindNullAtIndex:index];
	else {
#ifdef SQL_DEBUG
		NSString *string;
		[mValues addObject:(string = [NSString stringWithString:_string])];
#endif
		
		error = sqlite3_bind_text(mStmt, (int)index, [_string cStringUsingEncoding:NSUTF8StringEncoding], (int)[_string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], NULL);
		
		if (SQLITE_OK != error) {
			NSLog(@"%s.. [%@] failed to sqlite3_bind_text(%lu : %@), %d", __PRETTY_FUNCTION__, self.name, index, _string, error);
			return FALSE;
		}
	}
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)bindBlob:(NSData *)_data atIndex:(NSUInteger)index
{
	int error;
	NSData *data;
	
	if (_data == nil)
		return [self bindNullAtIndex:index];
	else {
#ifdef SQL_DEBUG
		[mValues addObject:(data = [NSData dataWithData:_data])];
#endif
		
		error = sqlite3_bind_blob(mStmt, (int)index, [data bytes], (int)[data length], NULL);
		
		if (SQLITE_OK != error) {
			NSLog(@"%s.. [%@] failed to sqlite3_bind_blob(%lu : %@), %d", __PRETTY_FUNCTION__, self.name, index, data, error);
			return FALSE;
		}
	}
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)bindDate:(NSDate *)date atIndex:(NSUInteger)index
{
	return [self bindString:[date description] atIndex:index];
}

/**
 *
 *
 */
- (BOOL)bindUint8:(NSUInteger)number atIndex:(NSUInteger)index
{
	int error;
	
#ifdef SQL_DEBUG
	[mValues addObject:[NSNumber numberWithUnsignedInteger:number]];
#endif

	error = sqlite3_bind_int(mStmt, (int)index, (uint8_t)number);
	
	if (SQLITE_OK != error) {
		NSLog(@"%s.. [%@] failed to sqlite3_bind_int(%lu : %lu), %d", __PRETTY_FUNCTION__, self.name, index, number, error);
		return FALSE;
	}
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)bindInt32:(NSInteger)number atIndex:(NSUInteger)index
{
	int error;
	
#ifdef SQL_DEBUG
	[mValues addObject:[NSNumber numberWithInteger:number]];
#endif
	
	error = sqlite3_bind_int(mStmt, (int)index, (int32_t)number);
	
	if (SQLITE_OK != error) {
		NSLog(@"%s.. [%@] failed to sqlite3_bind_int(%lu : %ld), %d", __PRETTY_FUNCTION__, self.name, index, number, error);
		return FALSE;
	}
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)bindUint32:(NSUInteger)number atIndex:(NSUInteger)index
{
	int error;
	
#ifdef SQL_DEBUG
	[mValues addObject:[NSNumber numberWithUnsignedInteger:number]];
#endif
	
	error = sqlite3_bind_int(mStmt, (int)index, (uint32_t)number);
	
	if (SQLITE_OK != error) {
		NSLog(@"%s.. [%@] failed to sqlite3_bind_int(%lu : %lu), %d", __PRETTY_FUNCTION__, self.name, index, number, error);
		return FALSE;
	}
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)bindUint64:(uint64_t)number atIndex:(NSUInteger)index
{
	int error;
	
#ifdef SQL_DEBUG
	[mValues addObject:[NSNumber numberWithUnsignedLong:number]];
#endif
	
	error = sqlite3_bind_int64(mStmt, (int)index, (uint64_t)number);
	
	if (SQLITE_OK != error) {
		NSLog(@"%s.. [%@] failed to sqlite3_bind_int64(%lu : %llu), %d", __PRETTY_FUNCTION__, self.name, index, number, error);
		return FALSE;
	}
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)bindFloat:(float)number atIndex:(NSUInteger)index
{
	int error;
	
#ifdef SQL_DEBUG
	[mValues addObject:[NSNumber numberWithFloat:number]];
#endif
	
	error = sqlite3_bind_double(mStmt, (int)index, (double)number);
	
	if (SQLITE_OK != error) {
		NSLog(@"%s.. [%@] failed to sqlite3_bind_double(%lu : %f), %d", __PRETTY_FUNCTION__, self.name, index, number, error);
		return FALSE;
	}
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)bindDouble:(double)number atIndex:(NSUInteger)index
{
	int error;
	
#ifdef SQL_DEBUG
	[mValues addObject:[NSNumber numberWithDouble:number]];
#endif
	
	error = sqlite3_bind_double(mStmt, (int)index, number);
	
	if (SQLITE_OK != error) {
		NSLog(@"%s.. [%@] failed to sqlite3_bind_double(%lu : %f), %d", __PRETTY_FUNCTION__, self.name, index, number, error);
		return FALSE;
	}
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)bindNullAtIndex:(NSUInteger)index
{
	int error;
	
#ifdef SQL_DEBUG
	[mValues addObject:[NSNull null]];
#endif
	
	error = sqlite3_bind_null(mStmt, (int)index);
	
	if (SQLITE_OK != error) {
		NSLog(@"%s.. [%@] failed to sqlite3_bind_null(%lu), %d", __PRETTY_FUNCTION__, self.name, index, error);
		return FALSE;
	}
	
	return TRUE;
}

@end
