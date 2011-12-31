//
//  DBResult.m
//  Get
//
//  Created by Curtis Jones on 2010.03.10.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import "DBResult.h"

@implementation DBResult

@synthesize isDone = mIsDone;
@synthesize document = mDocument;

#pragma mark - Abstract Methods

/**
 *
 *
 */
- (BOOL)next
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)getString:(NSString **)value atColumn:(NSUInteger)column
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)getBlob:(NSData **)value atColumn:(NSUInteger)column
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)getDate:(NSDate **)value atColumn:(NSUInteger)column
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)getInt32:(NSInteger *)value atColumn:(NSUInteger)column
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)getUint32:(NSUInteger *)value atColumn:(NSUInteger)column
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)getUint64:(uint64_t *)value atColumn:(NSUInteger)column
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)getFloat:(float *)value atColumn:(NSUInteger)column
{
	return FALSE;
}

/**
 *
 */
- (BOOL)getDouble:(double *)value atColumn:(NSUInteger)column
{
	return FALSE;
}

@end
