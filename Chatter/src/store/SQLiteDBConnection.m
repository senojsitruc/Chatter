//
//  SQLiteDBConnection.m
//  Get
//
//  Created by Curtis Jones on 2010.03.10.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import "SQLiteDBConnection.h"
#import "SQLiteDBResult.h"
#import "SQLiteDBStatement.h"
#import <stdlib.h>

@implementation SQLiteDBConnection

#pragma mark - Structors

/**
 *
 *
 */
- (id)initWithFileName:(NSString *)fileName
{
	self = [super init];
	
	if (self) {
		mConn = NULL;
		mFileName = [[NSString alloc] initWithString:fileName];
	}
	
	return self;
}

/**
 *
 *
 */
- (void)dealloc
{
	[mFileName release];
	
	// cleanly disconnect from the database
	if (mConn != NULL) {
		sqlite3_close(mConn);
		mConn = NULL;
	}
	
	[super dealloc];
}





#pragma mark - DBConnection

/**
 * Connect to database
 * Read version number
 * Incrementally update
 *   Write the new version number for each update
 * Disconnect from database
 *
 * Post notifications so that the UI can show useful information since this process could be lengthy.
 *
 */
- (BOOL)verify:(NSError **)nserror
{
	int error, version, curversion=5;
	sqlite3 *conn = NULL;
	BOOL retval = FALSE;
	NSString *errorstr = nil;
	
	// connect to the database. we don't care about multi-threading support and we _do not_ want the
	// database to enforce foreign key constraints since we're potentially going to be mucking about.
	if (SQLITE_OK != (error = sqlite3_open_v2([mFileName cStringUsingEncoding:NSUTF8StringEncoding], &conn, SQLITE_OPEN_READWRITE | SQLITE_OPEN_NOMUTEX, NULL))) {
		errorstr = [NSString stringWithFormat:@"Failed to sqlite3_open_v2(%@), %d", mFileName, error];
		goto done;
	}
	
	// select the database version number as stored in the "setting" table
	{
		sqlite3_stmt *select;
		
		if (SQLITE_OK != (error = sqlite3_prepare_v2(conn, "SELECT value FROM setting WHERE name=?", -1, &select, NULL))) {
			errorstr = [NSString stringWithFormat:@"Failed to sqlite_prepare_v2(), %d", error];
			goto done;
		}
		
		if (SQLITE_OK != (error = sqlite3_bind_text(select, 1, "Database Version", 16, NULL))) {
			errorstr = [NSString stringWithFormat:@"Failed to sqlite3_bind_text(), %d", error];
			goto done;
		}
		
		if (SQLITE_ROW == (error = sqlite3_step(select)))
			version = (int)strtol((const char *)sqlite3_column_text(select,0), NULL, 10);
		else {
			errorstr = [NSString stringWithFormat:@"Failed to select the database version record, %d", error];
			goto done;
		}
		
		sqlite3_clear_bindings(select);
		sqlite3_reset(select);
		sqlite3_finalize(select);
	}
	
	if (version != curversion) {
		errorstr = [NSString stringWithFormat:@"Unsupported database version: you've got v%d and we need v%d.", version, curversion];
		goto done;
	}
	
	retval = TRUE;
	
done:
	sqlite3_close(conn);
	
	if (!retval && errorstr) {
		NSDictionary *dictionary = [NSDictionary dictionaryWithObject:errorstr forKey:NSLocalizedDescriptionKey];
		*nserror = [NSError errorWithDomain:@"SQLiteDBConnection" code:0 userInfo:dictionary];
	}
	
	return retval;
}

/**
 *
 *
 */
- (BOOL)connect
{
	int error;
	
	error = sqlite3_open_v2([mFileName cStringUsingEncoding:NSUTF8StringEncoding], &mConn, SQLITE_OPEN_READWRITE | SQLITE_OPEN_NOMUTEX, NULL);
	
	if (SQLITE_OK != error) {
		NSLog(@"%s.. [%@] failed to connect, %s [%d]", __PRETTY_FUNCTION__, mFileName, sqlite3_errmsg(mConn), error);
		sqlite3_close(mConn);
		mConn = NULL;
		return FALSE;
	}
	
	// we don't want to artifically limit the amount of memory that sqlite will use
	sqlite3_soft_heap_limit(0);
	
	if (SQLITE_OK != (error = sqlite3_busy_timeout(mConn, 5000)))
		NSLog(@"%s.. failed to sqlite3_busy_timeout(), %d", __PRETTY_FUNCTION__, error);
	
	// enable foreign key support
	if (SQLITE_OK != (error = sqlite3_exec(mConn, "PRAGMA foreign_keys = ON", NULL, NULL, NULL))) {
		NSLog(@"%s.. failed to 'PRAGMA foreign_keys = ON', %d", __PRETTY_FUNCTION__, error);
		sqlite3_close(mConn);
		mConn = NULL;
		return FALSE;
	}
	
	// disable forced database file synchronization
	if (SQLITE_OK != (error = sqlite3_exec(mConn, "PRAGMA synchronous = OFF", NULL, NULL, NULL))) {
		NSLog(@"%s.. failed to 'PRAGMA synchronous = OFF', %d", __PRETTY_FUNCTION__, error);
		sqlite3_close(mConn);
		mConn = NULL;
		return FALSE;
	}
	
	// write ahead logging
	if (SQLITE_OK != (error = sqlite3_exec(mConn, "PRAGMA journal_mode = WAL", NULL, NULL, NULL))) {
		NSLog(@"%s.. failed to 'PRAGMA journal_mode = WAL', %d", __PRETTY_FUNCTION__, error);
		sqlite3_close(mConn);
		mConn = NULL;
		return FALSE;
	}
	
	// temporary tables and indicies
	if (SQLITE_OK != (error = sqlite3_exec(mConn, "PRAGMA temp_store = MEMORY", NULL, NULL, NULL))) {
		NSLog(@"%s.. failed to 'PRAGMA temp_store = MEMORY', %d", __PRETTY_FUNCTION__, error);
		sqlite3_close(mConn);
		mConn = NULL;
		return FALSE;
	}
	
	/* account */
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_account_insert.sql" andName:@"account_insert"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_account_update_by_id.sql" andName:@"account_update_by_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_account_delete_by_id.sql" andName:@"account_delete_by_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_account_select_all.sql" andName:@"account_select_all"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_account_select_count.sql" andName:@"account_select_count"]];
	
	/* message */
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_message_insert.sql" andName:@"message_insert"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_message_update_by_id.sql" andName:@"message_update_by_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_message_delete_by_id.sql" andName:@"message_delete_by_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_message_delete_by_account_id.sql" andName:@"message_delete_by_account_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_message_delete_by_person_id.sql" andName:@"message_delete_by_person_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_message_delete_by_session_id.sql" andName:@"message_delete_by_session_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_message_select_all.sql" andName:@"message_select_all"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_message_select_id_by_message.sql" andName:@"message_select_id_by_message"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_message_select_id_by_account_id.sql" andName:@"message_select_id_by_account_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_message_select_id_by_person_id.sql" andName:@"message_select_id_by_person_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_message_select_id_by_session_id.sql" andName:@"message_select_id_by_session_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_message_select_count.sql" andName:@"message_select_count"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_message_select_count_by_session_id.sql" andName:@"message_select_count_by_session_id"]];
	
	/* messageword */
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_messageword_insert.sql" andName:@"messageword_insert"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_messageword_select_all_by_word_id.sql" andName:@"messageword_select_all_by_word_id"]];
	
	/* person */
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_person_insert.sql" andName:@"person_insert"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_person_update_by_id.sql" andName:@"person_update_by_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_person_delete_by_id.sql" andName:@"person_delete_by_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_person_select_all.sql" andName:@"person_select_all"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_person_select_count.sql" andName:@"person_select_count"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_person_select_id_by_abuid.sql" andName:@"person_select_id_by_abuid"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_person_select_id_by_fn_ln.sql" andName:@"person_select_id_by_fn_ln"]];
	
	/* session */
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_session_insert.sql" andName:@"session_insert"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_session_update_by_id.sql" andName:@"session_update_by_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_session_delete_by_id.sql" andName:@"session_delete_by_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_session_select_all.sql" andName:@"session_select_all"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_session_select_count.sql" andName:@"session_select_count"]];
	
	/* sessionaccount */
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_sessionaccount_insert.sql" andName:@"sessionaccount_insert"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_sessionaccount_select_account_id_by_session_id.sql" andName:@"sessionaccount_select_account_id_by_session_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_sessionaccount_select_session_id_by_account_id.sql" andName:@"sessionaccount_select_session_id_by_account_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_sessionaccount_select_session_id_by_person_id.sql" andName:@"sessionaccount_select_session_id_by_person_id"]];
	
	/* setting */
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_setting_insert.sql" andName:@"setting_insert"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_setting_update_by_id.sql" andName:@"setting_update_by_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_setting_delete_by_id.sql" andName:@"setting_delete_by_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_setting_delete_by_name_value.sql" andName:@"setting_delete_by_name_value"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_setting_select_all.sql" andName:@"setting_select_all"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_setting_select_by_name.sql" andName:@"setting_select_by_name"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_setting_select_count.sql" andName:@"setting_select_count"]];
	
	/* source */
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_source_insert.sql" andName:@"source_insert"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_source_update_by_id.sql" andName:@"source_update_by_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_source_delete_by_id.sql" andName:@"source_delete_by_id"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_source_select_all.sql" andName:@"source_select_all"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_source_select_count.sql" andName:@"source_select_count"]];
	
	/* word */
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_word_insert.sql" andName:@"word_insert"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_word_select_all.sql" andName:@"word_select_all"]];
	[self setStatement:[SQLiteDBStatement statementWithSqlFile:@"sql_word_select_count.sql" andName:@"word_select_count"]];
	
	NSLog(@"%s.. [%@] connected [threadsafe=%d]", __PRETTY_FUNCTION__, mFileName, sqlite3_threadsafe());
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)disconnect
{
	@synchronized (self) {
		// cleanly disconnect from the database
		if (mConn != NULL) {
			sqlite3_close(mConn);
			mConn = NULL;
		}
	}
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)prepare:(DBStatement *)_statement
{
	int error;
	SQLiteDBStatement *statement = (SQLiteDBStatement*)_statement;
	
	if (mConn == NULL) {
		NSLog(@"%s.. null database connection", __PRETTY_FUNCTION__);
		return FALSE;
	}
	
	error = sqlite3_prepare_v2(mConn, [statement.query cStringUsingEncoding:NSUTF8StringEncoding], (int)[statement.query length], &statement->mStmt, NULL);
	
	if (SQLITE_OK != error || statement->mStmt == NULL) {
		NSLog(@"%s.. query = '%@'", __PRETTY_FUNCTION__, statement.query);
		NSLog(@"%s.. failed to sqlite3_prepare_v2(%@), %d", __PRETTY_FUNCTION__, statement.name, error);
		return FALSE;
	}
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)exec:(DBStatement *)_statement result:(DBResult **)_result
{
	SQLiteDBStatement *statement = (SQLiteDBStatement*)_statement;
	SQLiteDBResult **result = (SQLiteDBResult **)_result;
	
	if (statement->mStmt == NULL) {
		NSLog(@"%s.. [%@] prepared statement is unprepared", __PRETTY_FUNCTION__, statement.name);
		return FALSE;
	}
	
	*result = [[[SQLiteDBResult alloc] initWithStatement:statement] autorelease];
	
	return [*result next];
}

/**
 *
 *
 */
- (BOOL)lastInsertRowId:(NSUInteger *)rowId
{
	int64_t _rowid;
	
	if (mConn == NULL) {
		NSLog(@"%s.. null database connection", __PRETTY_FUNCTION__);
		return FALSE;
	}
	
	_rowid = sqlite3_last_insert_rowid(mConn);
	*rowId = (NSUInteger)_rowid;
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)rowsAffected:(NSUInteger *)rows
{
	int _rows = 0;
	
	if (mConn == NULL) {
		NSLog(@"%s.. null database connection", __PRETTY_FUNCTION__);
		return FALSE;
	}
	
	_rows = sqlite3_changes(mConn);
	*rows = (NSUInteger)_rows;
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)beginTransaction
{
	if (mConn == NULL) {
		NSLog(@"%s.. null database connection", __PRETTY_FUNCTION__);
		return FALSE;
	}
	
	sqlite3_exec(mConn, "begin", NULL, NULL, NULL);
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)commitTransaction
{
	if (mConn == NULL) {
		NSLog(@"%s.. null database connection", __PRETTY_FUNCTION__);
		return FALSE;
	}
	
	sqlite3_exec(mConn, "commit", NULL, NULL, NULL);
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)rollbackTransaction
{
	if (mConn == NULL) {
		NSLog(@"%s.. null database connection", __PRETTY_FUNCTION__);
		return FALSE;
	}
	
	sqlite3_exec(mConn, "rollback", NULL, NULL, NULL);
	
	return TRUE;
}

@end
