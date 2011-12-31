//
//  ChatterMessageWord+DBObject.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterMessageWord+DBObject.h"
#import "ChatterMessage+DBObject.h"
#import "ChatterWord+DBObject.h"
#import "DBConnection.h"
#import "DBResult.h"
#import "DBStatement.h"
#import "Easy.h"

@implementation ChatterMessageWord (DBObject)

/**
 *
 *
 */
+ (BOOL)dbobjectInsertWithMessage:(ChatterMessage *)message andWord:(ChatterWord *)word
{
	BOOL retval = TRUE;
	DBConnection *connection;
	DBResult *result = nil;
	DBStatement *statement;
	
	// from the element to the script to the document to the db connection
	if (nil == (connection = [Easy dbconn]))
		@throw [NSException exceptionWithName:ChatterExceptionNoDbConnection reason:[NSString stringWithFormat:@"[%@] No database connection.", NSStringFromClass([self class])] userInfo:nil];
	
	// get the prepared statement for this operation
	if (nil == (statement = [connection statementForName:@"messageword_insert"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindUint32:message.databaseId atIndex:1];
			[statement bindUint32:word.databaseId atIndex:2];
		}
		
		// execute statement
		[connection exec:statement result:&result];
		
	done:
		[statement clear];
	}
	
	return retval;
}

/**
 *
 *
 */
+ (BOOL)dbobjectSelectMessageIdsForWord:(ChatterWord *)cword withHandler:(BOOL (^)(NSUInteger))handler
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
	if (nil == (statement = [connection statementForName:@"messageword_select_all_by_word_id"]))
		@throw [NSException exceptionWithName:ChatterExceptionNoStatement reason:@"Could not find the required statement" userInfo:nil];
	
	@synchronized (connection) {
		// setup
		{
			[statement bindUint32:cword.databaseId atIndex:1];
		}
		
		// execute statement
		if (![connection exec:statement result:&result])
			DBOBJ_ERROR(statement,retval,done);
		
		// handle result
		while (![result isDone]) {
			[result getUint32:&messageId atColumn:0];
			
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
