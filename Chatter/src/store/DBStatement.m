//
//  DBStatement.m
//  Get
//
//  Created by Curtis Jones on 2010.03.10.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import "DBStatement.h"
#import "Easy.h"

@implementation DBStatement

@synthesize query = mQuery;
@synthesize name = mName;





#pragma mark - Structors

/**
 *
 *
 */
- (id)initWithQuery:(NSString *)query andName:(NSString *)name
{
	self = [super init];
	
	if (self) {
		mQuery = [[NSString alloc] initWithString:query];
		mName = [[NSString alloc] initWithString:name];
		mValues = [[NSMutableArray alloc] initWithCapacity:20];
	}
	
	return self;
}

/**
 *
 *
 */
- (id)initWithSqlFile:(NSString *)sqlfile andName:(NSString *)name
{
	self = [super init];
	
	if (self) {
		NSData *data = [NSData dataWithContentsOfFile:[[Easy sqlPath] stringByAppendingPathComponent:sqlfile]];
		
		if (data == nil || [data length] == 0)
			NSLog(@"%s.. failed to read file '%@'", __PRETTY_FUNCTION__, sqlfile);
		
		mQuery = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
		mName = [[NSString alloc] initWithString:name];
		mValues = [[NSMutableArray alloc] initWithCapacity:20];
	}
	
	return self;
}

/**
 *
 *
 */
- (void)dealloc
{
	[mQuery release];
	[mName release];
	[mValues release];
	
	[super dealloc];
}





#pragma mark -
#pragma mark Accessors

/**
 *
 *
 */
- (void)dump
{
	NSLog(@"%s.. [%@] %@", __PRETTY_FUNCTION__, mName, mQuery);
	
	for (int i = 0; i < [mValues count]; ++i)
		NSLog(@"  [%02d of %02lu] %@", i+1, [mValues count], [mValues objectAtIndex:i]);
}





#pragma mark - Abstract Methods

/**
 *
 *
 */
- (BOOL)clear
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)bindString:(NSString *)string atIndex:(NSUInteger)index
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)bindBlob:(NSData *)data atIndex:(NSUInteger)index
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)bindDate:(NSDate *)date atIndex:(NSUInteger)index
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)bindUint8:(NSUInteger)number atIndex:(NSUInteger)index
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)bindInt32:(NSInteger)number atIndex:(NSUInteger)index
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)bindUint32:(NSUInteger)number atIndex:(NSUInteger)index
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)bindUint64:(uint64_t)number atIndex:(NSUInteger)index
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)bindFloat:(float)number atIndex:(NSUInteger)index
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)bindDouble:(double)number atIndex:(NSUInteger)index
{
	return FALSE;
}

/**
 *
 *
 */
- (BOOL)bindNullAtIndex:(NSUInteger)index
{
	return FALSE;
}

@end