//
//  ChatterWord.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterWord.h"

@implementation ChatterWord

@synthesize word = mWord;

/**
 *
 *
 */
+ (id)word
{
	return [[[[self class] alloc] init] autorelease];
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
- (void)dealloc
{
	[mWord release];
	[super dealloc];
}

@end
