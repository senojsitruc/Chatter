//
//  ChatterAccount+DBObject.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterAccount+DBObject.h"
#import "DBConnection.h"
#import "DBResult.h"
#import "DBStatement.h"
#import "Easy.h"

@interface ChatterAccount (DBObjectPrivateMethods)
- (ChatterAccount *)__dbobjectHandleResult:(DBResult *)result;
@end

@implementation ChatterAccount (DBObject)

/**
 *
 *
 */
+ (BOOL)dbobjectSelectAllWithHandler:(BOOL (^)(ChatterAccount*))handler
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	ChatterAccount *object = nil;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"account_select_all"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// execute statement
		if (![connection exec:statement result:&result])
			DBOBJ_ERROR(statement,retval,done);
		
		// handle result
		DBOBJ_HANDLE2([ChatterAccount account], handler);
		
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
	if (nil == (statement = [connection statementForName:@"account_select_count"]))
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
	if (nil == (statement = [connection statementForName:@"account_insert"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// if this object already has a database key then don't insert it again
	if (mDatabaseId != 0)
		@throw [NSException exceptionWithName:ChatterExceptionIllegalOperation reason:@"Can not insert an already inserted object" userInfo:nil];
	
	/*
	if (mPersonId == 0 && mPerson != nil)
		mPersonId = mPerson.databaseId;
	*/
	
	@synchronized (connection) {
		// setup
		{
			if (mPersonId == 0)
				[statement bindNullAtIndex:1];
			else
				[statement bindUint32:mPersonId atIndex:1];
			
			[statement bindString:mScreenName atIndex:2];
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
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"account_update_by_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// the record must already have been inserted before we can attempt to update it
	if (mDatabaseId == 0)
		@throw [NSException exceptionWithName:ChatterExceptionIllegalOperation reason:@"Can not update a record that hasn't yet been inserted" userInfo:nil];
	
	/*
	if (mPersonId == 0 && mPerson != nil)
		mPersonId = mPerson.databaseId;
	*/
	
	@synchronized (connection) {
		// setup
		{
			if (mPersonId == 0)
				[statement bindNullAtIndex:1];
			else
				[statement bindUint32:mPersonId atIndex:1];
			
			[statement bindString:mScreenName atIndex:2];
			[statement bindUint32:mDatabaseId atIndex:3];
		}
		
		// execute statement
		if (![connection exec:statement result:&result])
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
	if (nil == (statement = [connection statementForName:@"account_delete_by_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// the record must already have been inserted before we can attempt to delete it
	if (mDatabaseId == 0)
		@throw [NSException exceptionWithName:ChatterExceptionIllegalOperation reason:@"Can not delete a record that hasn't yet been inserted" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		[statement bindUint32:mDatabaseId atIndex:1];
		
		// execute statement
		if (![connection exec:statement result:&result])
			DBOBJ_ERROR(statement,retval,done);
		
		[[self retain] autorelease];
		//[self.document __removeElement:self];
		
	done:
		[statement clear];
	}
	
	return retval;
}





#pragma mark -
#pragma mark Private

/**
 *
 *
 */
- (ChatterAccount *)__dbobjectHandleResult:(DBResult *)result
{
	[result getUint32:&mDatabaseId atColumn:0];
	[result getUint32:&mPersonId atColumn:1];
	[result getString:&mScreenName atColumn:2];
	
	return self;
}

@end
