//
//  ChatterMessage+DBObject.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterMessage+DBObject.h"
#import "ChatterAccount+DBObject.h"
#import "ChatterPerson+DBObject.h"
#import "ChatterSource+DBObject.h"
#import "DBConnection.h"
#import "DBResult.h"
#import "DBStatement.h"
#import "Easy.h"

@interface ChatterMessage (DBObjectPrivateMethods)
- (ChatterMessage *)__dbobjectHandleResult:(DBResult *)result;
@end

@implementation ChatterMessage (DBObject)

/**
 *
 *
 */
+ (NSUInteger)dbobjectSelectIdForTimestamp:(NSString *)timestamp sessionId:(NSUInteger)sessionId screenName:(NSString *)screenName message:(NSString *)message;
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	NSUInteger messageId = 0;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"message_select_id_by_message"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindString:timestamp atIndex:1];
			[statement bindUint32:sessionId atIndex:2];
			[statement bindString:screenName atIndex:3];
			[statement bindString:message atIndex:4];
		}
		
		// execute statement
		if (!(result = [connection exec:statement]))
			DBOBJ_ERROR(statement,retval,done);
		
		messageId = [result getUint32AtColumn:0];
		
	done:
		[statement clear];
	}
	
	return messageId;
}

/**
 *
 *
 */
+ (NSUInteger)dbobjectSelectCountForSessionId:(NSUInteger)sessionId
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
	if (nil == (statement = [connection statementForName:@"message_select_count_by_session_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindUint32:sessionId atIndex:1];
		}
		
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
+ (BOOL)dbobjectDeleteForSessionId:(NSUInteger)sessionId
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"message_delete_by_session_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindUint32:sessionId atIndex:1];
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
+ (BOOL)dbobjectDeleteForAccount:(ChatterAccount *)caccount
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"message_delete_by_account_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// the record must already have been inserted before we can attempt to delete it
	if (caccount.databaseId == 0)
		@throw [NSException exceptionWithName:ChatterExceptionIllegalOperation reason:@"Can not delete a record that hasn't yet been inserted" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		[statement bindUint32:caccount.databaseId atIndex:1];
		
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
+ (BOOL)dbobjectDeleteForPerson:(ChatterPerson *)cperson
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"message_delete_by_person_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// the record must already have been inserted before we can attempt to delete it
	if (cperson.databaseId == 0)
		@throw [NSException exceptionWithName:ChatterExceptionIllegalOperation reason:@"Can not delete a record that hasn't yet been inserted" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		[statement bindUint32:cperson.databaseId atIndex:1];
		
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
+ (NSArray *)dbobjectSelectAllWithHandler:(BOOL (^)(ChatterMessage*))handler
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	ChatterMessage *object = nil;
	NSMutableArray *objects = [NSMutableArray array];
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"message_select_all"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// execute statement
		if (!(result = [connection exec:statement]))
			DBOBJ_ERROR(statement,retval,done);
		
		// handle result
		DBOBJ_HANDLE2([ChatterMessage message], handler);
		
	done:
		[statement clear];
	}
	
	return objects;
}

/**
 *
 *
 */
+ (BOOL)dbobjectSelectIDsForAccount:(ChatterAccount *)caccount withHandler:(BOOL (^) (NSUInteger))handler
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	NSUInteger messageId;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"message_select_id_by_account_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindUint32:caccount.databaseId atIndex:1];
		}
		
		// execute statement
		if (!(result = [connection exec:statement]))
			DBOBJ_ERROR(statement,retval,done);
		
		// handle result
		while (![result isDone]) {
			messageId = [result getUint32AtColumn:0];
			
			if (FALSE == handler(messageId))
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
+ (BOOL)dbobjectSelectIDsForPerson:(ChatterPerson *)cperson withHandler:(BOOL (^) (NSUInteger))handler
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	NSUInteger messageId;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"message_select_id_by_person_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindUint32:cperson.databaseId atIndex:1];
		}
		
		// execute statement
		if (!(result = [connection exec:statement]))
			DBOBJ_ERROR(statement,retval,done);
		
		// handle result
		while (![result isDone]) {
			messageId = [result getUint32AtColumn:0];
			
			if (FALSE == handler(messageId))
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
+ (BOOL)dbobjectSelectIDsForSessionId:(NSUInteger)sessionId withHandler:(BOOL (^) (NSUInteger))handler
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
	if (nil == (statement = [connection statementForName:@"message_select_id_by_session_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindUint32:sessionId atIndex:1];
		}
		
		// execute statement
		if (!(result = [connection exec:statement]))
			DBOBJ_ERROR(statement,retval,done);
		
		// handle result
		while (![result isDone]) {
			databaseId = [result getUint32AtColumn:0];
			
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
	if (nil == (statement = [connection statementForName:@"message_select_count"]))
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
	if (nil == (statement = [connection statementForName:@"message_insert"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// if this object already has a database key then don't insert it again
	if (mDatabaseId != 0)
		@throw [NSException exceptionWithName:ChatterExceptionIllegalOperation reason:@"Can not insert an already inserted object" userInfo:nil];
	
	if (mAccountId == 0 && mAccount != nil)
		mAccountId = mAccount.databaseId;
	
	if (mSourceId == 0)
		mSourceId = mSource.databaseId;
	
	@synchronized (connection) {
		// setup
		{
			if (mAccountId == 0)
				[statement bindNullAtIndex:1];
			else
				[statement bindUint32:mAccountId atIndex:1];
			
			[statement bindUint32:mSourceId atIndex:2];
			[statement bindUint32:mSessionId atIndex:3];
			[statement bindString:self.timestampStr atIndex:4];
			[statement bindUint32:mRenderWidth atIndex:5];
			[statement bindUint32:mRenderHeight atIndex:6];
			[statement bindString:mMessage atIndex:7];
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
	if (nil == (statement = [connection statementForName:@"message_update_by_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	// the record must already have been inserted before we can attempt to update it
	if (mDatabaseId == 0)
		@throw [NSException exceptionWithName:ChatterExceptionIllegalOperation reason:@"Can not update a record that hasn't yet been inserted" userInfo:nil];
	
	if (mAccountId == 0 && mAccount != nil)
		mAccountId = mAccount.databaseId;
	
	if (mSourceId == 0)
		mSourceId = mSource.databaseId;
	
	@synchronized (connection) {
		// setup
		{
			if (mAccountId == 0)
				[statement bindNullAtIndex:1];
			else
				[statement bindUint32:mAccountId atIndex:1];
			
			[statement bindUint32:mSourceId atIndex:2];
			[statement bindUint32:mSessionId atIndex:3];
			[statement bindString:self.timestampStr atIndex:4];
			[statement bindUint32:mRenderWidth atIndex:5];
			[statement bindUint32:mRenderHeight atIndex:6];
			[statement bindString:mMessage atIndex:7];
			[statement bindUint32:mDatabaseId atIndex:8];
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
	if (nil == (statement = [connection statementForName:@"message_delete_by_id"]))
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





#pragma mark -
#pragma mark Private

/**
 *
 *
 */
- (ChatterMessage *)__dbobjectHandleResult:(DBResult *)result
{
	mDatabaseId = [result getUint32AtColumn:0];
	mAccountId = [result getUint32AtColumn:1];
	mSourceId = [result getUint32AtColumn:2];
	mSessionId = [result getUint32AtColumn:3];
	mTimestampStr = [result getStringAtColumn:4];
	mRenderWidth = [result getUint32AtColumn:5];
	mRenderHeight = [result getUint32AtColumn:6];
	mMessage = [result getStringAtColumn:7];
	
	return self;
}

@end
