//
//  ChatterSource+DBObject.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterSource+DBObject.h"
#import "DBConnection.h"
#import "DBResult.h"
#import "DBStatement.h"
#import "Easy.h"

@interface ChatterSource (DBObjectPrivateMethods)
- (ChatterSource *)__dbobjectHandleResult:(DBResult *)result;
@end

@implementation ChatterSource (DBObject)

/**
 *
 *
 */
+ (BOOL)dbobjectSelectAllWithHandler:(BOOL (^)(ChatterSource*))handler
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	ChatterSource *object = nil;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"source_select_all"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// execute statement
		if (!(result = [connection exec:statement]))
			DBOBJ_ERROR(statement,retval,done);
		
		// handle result
		DBOBJ_HANDLE2([ChatterSource source], handler);
		
	done:
		[statement clear];
	}
	
	return retval;
}

/**
 *
 *
 */
+ (NSUInteger)dbobjectSelectCount
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	NSUInteger count = 0;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"source_select_count"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// execute statement
		if (!(result = [connection exec:statement]))
			DBOBJ_ERROR(statement,retval,done);
		
		count = [result getUint32AtColumn:0];
		
	done:
		[statement clear];
	}
	
	return count;
}

/**
 *
 *
 */
- (BOOL)dbobjectInsert
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"source_insert"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// if this object already has a database key then don't insert it again
	if (mDatabaseId != 0)
		@throw [NSException exceptionWithName:ChatterExceptionIllegalOperation reason:@"Can not insert an already inserted object" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindString:mService atIndex:1];
			[statement bindString:mFilePath atIndex:2];
			[statement bindNullAtIndex:3];
			[statement bindDate:self.timestamp atIndex:4];
		}
		
		// execute statement
		if (!(result = [connection exec:statement]))
			DBOBJ_ERROR(statement,retval,done);
		
		// get primary key
		if (FALSE == [connection lastInsertRowId:&mDatabaseId])
			NSLog(@"%s.. failed to lastInsertRowId()", __PRETTY_FUNCTION__);
		
	done:
		[statement clear];
	}
	
	return retval;
}

/**
 *
 *
 */
- (BOOL)dbobjectUpdate
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"source_update_by_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// the record must already have been inserted before we can attempt to update it
	if (mDatabaseId == 0)
		@throw [NSException exceptionWithName:ChatterExceptionIllegalOperation reason:@"Can not update a record that hasn't yet been inserted" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindString:mService atIndex:1];
			[statement bindString:mFilePath atIndex:2];
			[statement bindNullAtIndex:3];
			[statement bindDate:self.timestamp atIndex:4];
			[statement bindUint32:mDatabaseId atIndex:5];
		}
		
		// execute statement
		if (!(result = [connection exec:statement]))
			DBOBJ_ERROR(statement,retval,done);
		
	done:
		[statement clear];
	}
	
	return retval;
}

/**
 *
 *
 */
- (BOOL)dbobjectDelete
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"source_delete_by_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// the record must already have been inserted before we can attempt to delete it
	if (mDatabaseId == 0)
		@throw [NSException exceptionWithName:ChatterExceptionIllegalOperation reason:@"Can not delete a record that hasn't yet been inserted" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		[statement bindUint32:mDatabaseId atIndex:1];
		
		// execute statement
		if (!(result = [connection exec:statement]))
			DBOBJ_ERROR(statement,retval,done);
		
	done:
		[statement clear];
	}
	
	return retval;
}





#pragma mark - Private

/**
 *
 *
 */
- (ChatterSource *)__dbobjectHandleResult:(DBResult *)result
{
	mDatabaseId = [result getUint32AtColumn:0];
	mService = [result getStringAtColumn:1];
	mFilePath = [result getStringAtColumn:2];
	mTimestampStr = [result getStringAtColumn:4];
	
	return self;
}

@end
