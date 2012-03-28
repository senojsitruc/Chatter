//
//  ChatterSetting.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterSetting.h"

@implementation ChatterSetting

@synthesize name = mName;
@synthesize valueString = mValue;
@dynamic valueInteger;





#pragma mark - Structors

/**
 *
 *
 */
+ (id)setting
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





#pragma mark - Accessors

/**
 *
 *
 */
- (NSInteger)valueInteger
{
	if (mValue == nil || [mValue length] == 0)
		return 0;
	else
		return [mValue integerValue];
}

/**
 *
 *
 */
- (void)setValueNumber:(NSInteger)value
{
	mValue = nil;
	mValue = [[NSNumber numberWithInteger:value] stringValue];
}

@end
