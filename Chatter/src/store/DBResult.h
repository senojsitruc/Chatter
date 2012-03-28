//
//  DBResult.h
//  Get
//
//  Created by Curtis Jones on 2010.03.10.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CZDocument;

@interface DBResult : NSObject
{
	BOOL mIsDone;
	CZDocument *__unsafe_unretained mDocument;                // weak reference to an optional document object
}

@property (readonly) BOOL isDone;
@property (readwrite, unsafe_unretained) CZDocument *document;

/**
 *
 */
- (BOOL)next;

/**
 *
 */
- (NSString *)getStringAtColumn:(NSUInteger)column;

/**
 *
 */
- (NSData *)getBlobAtColumn:(NSUInteger)column;

/**
 *
 */
- (NSDate *)getDateAtColumn:(NSUInteger)column;

/**
 *
 */
- (NSInteger)getInt32AtColumn:(NSUInteger)column;

/**
 *
 */
- (NSUInteger)getUint32AtColumn:(NSUInteger)column;

/**
 *
 */
- (uint64_t)getUint64AtColumn:(NSUInteger)column;

/**
 *
 */
- (float)getFloatAtColumn:(NSUInteger)column;

/**
 *
 */
- (double)getDoubleAtColumn:(NSUInteger)column;

@end
