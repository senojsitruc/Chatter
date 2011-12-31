//
//  VersionChecker.m
//  Chatter
//
//  Created by Jones Curtis on 2011.07.06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VersionChecker.h"

static VersionChecker *gVersionChecker;

@implementation VersionChecker

/**
 *
 *
 */
+ (void)initialize
{
	gVersionChecker = [[[self class] alloc] init];
}

/**
 *
 *
 */
+ (id)sharedInstance
{
	return gVersionChecker;
}

/**
 *
 *
 */
- (id)init
{
	self = [super init];
	
	if (self) {
		// ...
	}
	
	return self;
}

/**
 *
 *
 */
- (void)checkWithHandler:(void (^)(NSString*, NSUInteger, NSError*))handler
{
	NSError *error = nil;
	NSURL *url = [NSURL URLWithString:@"http://curtisjones.us/chatter/Version.plist"];
	NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
	
	if (error != nil) {
		handler(nil, 0, error);
	}
	else {
		NSDictionary *versionInfo = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:&error];
		NSDictionary *release = [versionInfo objectForKey:@"Release"];
		NSString *version = [release objectForKey:@"Version"];
		NSString *build = [release objectForKey:@"Build"];
		
		handler(version, [build integerValue], error);
	}
}

@end
