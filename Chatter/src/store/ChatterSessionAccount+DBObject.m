//
//  ChatterSessionAccount+DBObject.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterSessionAccount+DBObject.h"
#import "DBConnection.h"
#import "DBResult.h"
#import "DBStatement.h"
#import "Easy.h"
#import "ChatterAccount.h"
#import "ChatterPerson.h"
#import "ChatterSession.h"

@implementation ChatterSessionAccount (DBObject)

/**
 *
 *
 */
+ (BOOL)dbobjectSelectAccountIDsForSession:(ChatterSession *)csession withHandler:(BOOL (^)(NSUInteger))handler;
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	NSUInteger databaseId;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"sessionaccount_select_account_id_by_session_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindUint32:csession.databaseId atIndex:1];
		}
		
		// execute statement
		if (![connection exec:statement result:&result])
			DBOBJ_ERROR(statement,retval,done);
		
		// handle result
		while (![result isDone]) {
			[result getUint32:&databaseId atColumn:0];
			
			if (FALSE == handler(databaseId))
				break;
			
			[result next];
		}
		
	done:
		[statement clear];
	}
	
	return retval;
}

/**
 *
 *
 */
+ (BOOL)dbobjectSelectSessionIDsForAccount:(ChatterAccount *)caccount withHandler:(BOOL (^)(NSUInteger))handler
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	NSUInteger databaseId;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"sessionaccount_select_session_id_by_account_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindUint32:caccount.databaseId atIndex:1];
		}
		
		// execute statement
		if (![connection exec:statement result:&result])
			DBOBJ_ERROR(statement,retval,done);
		
		// handle result
		while (![result isDone]) {
			[result getUint32:&databaseId atColumn:0];
			
			if (FALSE == handler(databaseId))
				break;
			
			[result next];
		}
		
	done:
		[statement clear];
	}
	
	return retval;
}

/**
 *
 *
 */
+ (BOOL)dbobjectSelectSessionIDsForPerson:(ChatterPerson *)cperson withHandler:(BOOL (^)(NSUInteger))handler
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	NSUInteger databaseId;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"sessionaccount_select_session_id_by_person_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindUint32:cperson.databaseId atIndex:1];
		}
		
		// execute statement
		if (![connection exec:statement result:&result])
			DBOBJ_ERROR(statement,retval,done);
		
		// handle result
		while (![result isDone]) {
			[result getUint32:&databaseId atColumn:0];
			
			if (FALSE == handler(databaseId))
				break;
			
			[result next];
		}
		
	done:
		[statement clear];
	}
	
	return retval;
}

/**
 *
 *
 */
+ (BOOL)dbobjectInsertWithSession:(ChatterSession *)session andAccount:(ChatterAccount *)account
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"sessionaccount_insert"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindUint32:session.databaseId atIndex:1];
			[statement bindUint32:account.databaseId atIndex:2];
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
- (BOOL)dbobjectInsert
{
	return TRUE;
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

@end
