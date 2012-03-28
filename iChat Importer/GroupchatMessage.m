//
//  GroupchatMessage.m
//  Chatter
//
//  Created by Curtis Jones on 2012.03.26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GroupchatMessage.h"

/*
@interface MyKeyedUnarchiver : NSKeyedUnarchiver
{
	id                   _delegate;
	NSMutableDictionary *_nameToReplacementClass;
	NSDictionary        *_propertyList;
	NSArray             *_objects;
	NSMutableArray      *_plistStack;
	NSMapTable          *_uidToObject;
	NSMapTable          *_objectToUid;
	NSMapTable          *_classVersions;
	
	int                  _unnamedKeyIndex;
}

@end
*/

@implementation GroupchatMessage

- (void)encodeWithCoder:(NSCoder *)encoder
{
	NSLog(@"encodeWithCoder called on %@", [self class]);
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ([decoder allowsKeyedCoding]) {
//	service = [decoder decodeObjectForKey:@"ServiceName"];
//	senderID = [decoder decodeObjectForKey:@"ID"];
	}
	else {
//	service = [decoder decodeObject];
//	senderID = [decoder decodeObject];
	}
	
	return self;
}

@end
