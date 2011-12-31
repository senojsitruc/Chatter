//
//  ChatterObject.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatterObject : NSObject
{
@protected
	NSUInteger mDatabaseId;
	NSUInteger mDeleted;
	NSUInteger mObjectId;
}

@property (readwrite, assign) NSUInteger databaseId;
@property (readwrite, assign) NSUInteger deleted;
@property (readonly) NSUInteger objectId;

+ (id)objectWithObjectId:(NSUInteger)objectId;
+ (id)objectWithDatabaseId:(NSUInteger)databaseId;
- (id)initWithObjectId:(NSUInteger)objectId;

@end
