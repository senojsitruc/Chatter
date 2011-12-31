//
//  ChatterWord+DBObject.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterWord+DBObject.h"
#import "DBConnection.h"
#import "DBResult.h"
#import "DBStatement.h"
#import "Easy.h"

@interface ChatterWord (DBObjectPrivateMethods)
- (ChatterWord *)__dbobjectHandleResult:(DBResult *)result;
@end

@implementation ChatterWord (DBObject)

/**
 *
 *
 */
+ (BOOL)dbobjectSelectAllWithHandler:(BOOL (^)(ChatterWord*))handler
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	ChatterWord *object = nil;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"word_select_all"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// execute statement
		if (![connection exec:statement result:&result])
			DBOBJ_ERROR(statement,retval,done);
		
		// handle result
		DBOBJ_HANDLE2([ChatterWord word], handler);
		
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
	if (nil == (statement = [connection statementForName:@"word_select_count"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// execute statement
		if (![connection exec:statement result:&result])
			DBOBJ_ERROR(statement,retval,done);
		
		[result getUint32:&count atColumn:0];
		
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
	if (nil == (statement = [connection statementForName:@"word_insert"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// if this object already has a database key then don't insert it again
	if (mDatabaseId != 0)
		@throw [NSException exceptionWithName:ChatterExceptionIllegalOperation reason:@"Can not insert an already inserted object" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindString:mWord atIndex:1];
		}
		
		// execute statement
		if (![connection exec:statement result:&result])
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
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)dbobjectDelete
{
	return TRUE;
}





#pragma mark -
#pragma mark Private

/**
 *
 *
 */
- (ChatterWord *)__dbobjectHandleResult:(DBResult *)result
{
	[result getUint32:&mDatabaseId atColumn:0];
	[result getString:&mWord atColumn:1];
	
	return self;
}

@end
