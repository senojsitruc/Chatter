//
//  DBConnection.m
//  Get
//
//  Created by Curtis Jones on 2010.03.10.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import "DBConnection.h"

NSString * const DBConnectionNoSuchStatementException = @"DBConnectionNoSuchStatementException";

@implementation DBConnection

#pragma mark - Structors

/**
 *
 *
 */
- (id)init
{
	self = [super init];
	
	if (self) {
		mStatements = [[NSMutableDictionary alloc] initWithCapacity:100];
	}
	
	return self;
}





#pragma mark - Abstract Methods

/**
 *
 *
 */
- (BOOL)verify:(NSError **)error
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)connect
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)disconnect
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)prepare:(DBStatement *)statement
{
	return FALSE;
}

/**
 *
 *
 */
- (DBResult *)exec:(DBStatement *)statement
{
	return nil;
}

/**
 * Don't worry about synchronizing on mStatements, because all of the statements are added before
 * the connection is used.
 *
 */
- (void)setStatement:(DBStatement *)statement
{
	[self prepare:statement];
	[mStatements setObject:statement forKey:statement.name];
}

/**
 *
 *
 */
- (DBStatement *)statementForName:(NSString *)statementName
{
	DBStatement *statement;
	
	if (nil == (statement = [mStatements objectForKey:statementName]))
		@throw [NSException exceptionWithName:DBConnectionNoSuchStatementException reason:[NSString stringWithFormat:@"No statement for name, '%@'", statementName] userInfo:nil];
	
	[statement clear];
	
	return statement;
}

/**
 *
 *
 */
- (BOOL)lastInsertRowId:(NSUInteger *)rowId
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)rowsAffected:(NSUInteger *)rows
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)beginTransaction
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)commitTransaction
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)rollbackTransaction
{
	return FALSE;
}

@end
