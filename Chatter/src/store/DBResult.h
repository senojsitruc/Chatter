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
	CZDocument *mDocument;                // weak reference to an optional document object
}

@property (readonly) BOOL isDone;
@property (readwrite, assign) CZDocument *document;

/**
 *
 */
- (BOOL)next;

/**
 *
 */
- (BOOL)getString:(NSString **)value atColumn:(NSUInteger)column;

/**
 *
 */
- (BOOL)getBlob:(NSData **)value atColumn:(NSUInteger)column;

/**
 *
 */
- (BOOL)getDate:(NSDate **)value atColumn:(NSUInteger)column;

/**
 *
 */
- (BOOL)getInt32:(NSInteger *)value atColumn:(NSUInteger)column;

/**
 *
 */
- (BOOL)getUint32:(NSUInteger *)value atColumn:(NSUInteger)column;

/**
 *
 */
- (BOOL)getUint64:(uint64_t *)value atColumn:(NSUInteger)column;

/**
 *
 */
- (BOOL)getFloat:(float *)value atColumn:(NSUInteger)column;

/**
 *
 */
- (BOOL)getDouble:(double *)value atColumn:(NSUInteger)column;

@end
