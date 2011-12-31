//
//  SQLiteDBConnection.h
//  Get
//
//  Created by Curtis Jones on 2010.03.10.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBConnection.h"
#import "DBStatement.h"
#import "../extern/sqlite3/sqlite3.h"

@interface SQLiteDBConnection : DBConnection
{
	NSString *mFileName;              // database file name
	sqlite3 *mConn;                   // sqlite3 connection object
}

/**
 *
 */
- (id)initWithFileName:(NSString *)fileName;

/**
 *
 */
- (BOOL)verify:(NSError **)error;

/**
 *
 */
- (BOOL)connect;

/**
 *
 */
- (BOOL)disconnect;

/**
 *
 */
- (BOOL)prepare:(DBStatement *)statement;

/**
 *
 */
- (BOOL)exec:(DBStatement *)statement result:(DBResult **)result;

/**
 *
 */
- (BOOL)lastInsertRowId:(NSUInteger *)rowId;

/**
 *
 */
- (BOOL)rowsAffected:(NSUInteger *)rows;

/**
 *
 */
- (BOOL)beginTransaction;

/**
 *
 */
- (BOOL)commitTransaction;

/**
 *
 */
- (BOOL)rollbackTransaction;

@end
