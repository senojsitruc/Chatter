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
	return [[[self class] alloc] init];
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

@end
