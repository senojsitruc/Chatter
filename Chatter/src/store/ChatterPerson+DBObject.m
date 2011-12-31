//
//  ChatterPerson+DBObject.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterPerson+DBObject.h"
#import "ChatterObjectCache.h"
#import "DBConnection.h"
#import "DBResult.h"
#import "DBStatement.h"
#import "Easy.h"

@interface ChatterPerson (PrivateMethods)
- (ChatterPerson *)__dbobjectHandleResult:(DBResult *)result;
@end

@implementation ChatterPerson (DBObject)

/**
 *
 *
 */
+ (BOOL)dbobjectSelectAllWithHandler:(BOOL (^)(ChatterPerson*))handler
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	ChatterPerson *object = nil;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"person_select_all"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// execute statement
		if (![connection exec:statement result:&result])
			DBOBJ_ERROR(statement,retval,done);
		
		// handle result
		DBOBJ_HANDLE2([ChatterPerson person], handler);
		
	done:
		[statement clear];
	}
	
	return retval;
}

/**
 *
 *
 */
+ (ChatterPerson *)dbobjectSelectByFirstName:(NSString *)firstName andLastName:(NSString *)lastName
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	ChatterPerson *person = nil;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"person_select_id_by_fn_ln"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// setup
	{
		[statement bindString:firstName atIndex:1];
		[statement bindString:lastName atIndex:2];
	}
	
	@synchronized (connection) {
		NSUInteger databaseId = 0;
		
		// execute statement
		if (![connection exec:statement result:&result])
			DBOBJ_ERROR(statement,retval,done);
		
		if (![result isDone]) {
			[result getUint32:&databaseId atColumn:0];
			person = [[ChatterObjectCache sharedInstance] personForId:databaseId];
		}
		
	done:
		[statement clear];
	}
	
	return person;
}

/**
 *
 *
 */
+ (NSUInteger)dbobjectSelectIdByAddressBookUid:(NSString *)addressBookUid
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	NSUInteger databaseId = 0;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"person_select_id_by_abuid"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// setup
	{
		[statement bindString:addressBookUid atIndex:1];
	}
	
	@synchronized (connection) {
		// execute statement
		if (![connection exec:statement result:&result])
			DBOBJ_ERROR(statement,retval,done);
		
		if (![result isDone])
			[result getUint32:&databaseId atColumn:0];
		
	done:
		[statement clear];
	}
	
	return databaseId;
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
	if (nil == (statement = [connection statementForName:@"person_select_count"]))
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
	if (nil == (statement = [connection statementForName:@"person_insert"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// if this object already has a database key then don't insert it again
	if (mDatabaseId != 0)
		@throw [NSException exceptionWithName:ChatterExceptionIllegalOperation reason:@"Can not insert an already inserted object" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			if ([mFirstName length] == 0)
				[statement bindNullAtIndex:1];
			else
				[statement bindString:mFirstName atIndex:1];
			
			if ([mLastName length] == 0)
				[statement bindNullAtIndex:2];
			else
				[statement bindString:mLastName atIndex:2];
			
			if ([mAddressBookUid length] == 0)
				[statement bindNullAtIndex:3];
			else
				[statement bindString:mAddressBookUid atIndex:3];
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
	if (nil == (statement = [connection statementForName:@"person_update_by_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// the record must already have been inserted before we can attempt to update it
	if (mDatabaseId == 0)
		@throw [NSException exceptionWithName:ChatterExceptionIllegalOperation reason:@"Can not update a record that hasn't yet been inserted" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			if ([mFirstName length] == 0)
				[statement bindNullAtIndex:1];
			else
				[statement bindString:mFirstName atIndex:1];
			
			if ([mLastName length] == 0)
				[statement bindNullAtIndex:2];
			else
				[statement bindString:mLastName atIndex:2];
			
			if ([mAddressBookUid length] == 0)
				[statement bindNullAtIndex:3];
			else
				[statement bindString:mAddressBookUid atIndex:3];
			
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
	if (nil == (statement = [connection statementForName:@"person_delete_by_id"]))
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





#pragma mark - Private

/**
 *
 *
 */
- (ChatterPerson *)__dbobjectHandleResult:(DBResult *)result
{
	[result getUint32:&mDatabaseId atColumn:0];
	[result getString:&mFirstName atColumn:1];
	[result getString:&mLastName atColumn:2];
	[result getString:&mAddressBookUid atColumn:3];
	
	return self;
}

@end
