//
//  ChatterObject.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterObject.h"

static NSUInteger gObjectId = 1000000000U;

@implementation ChatterObject

@synthesize databaseId = mDatabaseId;
@synthesize deleted = mDeleted;
@synthesize objectId = mObjectId;





#pragma mark - Structors

/**
 *
 *
 */
+ (id)objectWithObjectId:(NSUInteger)objectId
{
	return [[[[self class] alloc] initWithObjectId:objectId] autorelease];
}

/**
 *
 *
 */
+ (id)objectWithDatabaseId:(NSUInteger)databaseId
{
	ChatterObject *object = [[[self class] alloc] init];
	object->mDatabaseId = databaseId;
	return object;
}

/**
 *
 *
 */
- (id)init
{
	self = [super init];
	
	if (self) {
		mObjectId = ++gObjectId;
		mDatabaseId = 0;
		mDeleted = 0;
	}
	
	return self;
}

/**
 *
 *
 */
- (id)initWithObjectId:(NSUInteger)objectId
{
	self = [super init];
	
	if (self) {
		mObjectId = objectId;
		mDatabaseId = 0;
		mDeleted = 0;
	}
	
	return self;
}

/**
 *
 *
 */
- (void)dealloc
{
	[super dealloc];
}





#pragma mark - NSObject

/**
 *
 *
 */
- (id)copyWithZone:(NSZone *)zone
{
	ChatterObject *object = [[[self class] allocWithZone:zone] init];
	
	object->mDatabaseId = mDatabaseId;
	object->mObjectId = mObjectId;
	
	return object;
}

/**
 *
 *
 */
- (NSUInteger)hash
{
	if (mDatabaseId != 0)
		return mDatabaseId;
	else
		return mObjectId;
}

/**
 *
 *
 */
- (BOOL)isEqual:(id)object
{
	return [self hash] == [object hash];
}

@end
