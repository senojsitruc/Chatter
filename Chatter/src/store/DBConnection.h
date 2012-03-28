//
//  DBConnection.h
//  Get
//
//  Created by Curtis Jones on 2010.03.10.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBResult.h"
#import "DBStatement.h"

extern NSString * const DBConnectionNoSuchStatementException;

@interface DBConnection : NSObject
{
	NSMutableDictionary *mStatements; // prepared statements
}

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
- (DBResult *)exec:(DBStatement *)statement;

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
- (void)setStatement:(DBStatement *)statement;

/**
 *
 */
- (DBStatement *)statementForName:(NSString *)statementName;

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
