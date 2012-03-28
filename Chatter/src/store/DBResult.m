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
- (NSString *)getStringAtColumn:(NSUInteger)column
{
	return nil;
}

/**
 *
 *
 */
- (NSData *)getBlobAtColumn:(NSUInteger)column
{
	return nil;
}

/**
 *
 *
 */
- (NSDate *)getDateAtColumn:(NSUInteger)column
{
	return nil;
}

/**
 *
 *
 */
- (NSInteger)getInt32AtColumn:(NSUInteger)column
{
	return 0;
}

/**
 *
 *
 */
- (NSUInteger)getUint32AtColumn:(NSUInteger)column
{
	return 0;
}

/**
 *
 *
 */
- (uint64_t)getUint64AtColumn:(NSUInteger)column
{
	return 0;
}

/**
 *
 *
 */
- (float)getFloatAtColumn:(NSUInteger)column
{
	return 0.;
}

/**
 *
 *
 */
- (double)getDoubleAtColumn:(NSUInteger)column
{
	return 0.;
}

@end
