//
//  InstantMessage.m
//  Logtastic
//
//  Created by Ladd Van Tol on Fri Mar 28 2003.
//  Copyright (c) 2003 Spiny. All rights reserved.
//

#import "InstantMessage.h"

@implementation InstantMessage

@synthesize sender;
@synthesize date;
@synthesize text;
@synthesize flags;

- (void)encodeWithCoder:(NSCoder *)encoder
{
	NSLog(@"encodeWithCoder called on %@", [self class]);
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ([decoder allowsKeyedCoding])
	{
		sender = [decoder decodeObjectForKey:@"Sender"];
		text = [decoder decodeObjectForKey:@"MessageText"];
		date = [decoder decodeObjectForKey:@"Time"];
		flags = [decoder decodeInt32ForKey:@"Flags"];
	}
	else
	{
		sender = [decoder decodeObject];
		date = [decoder decodeObject];
		text = [decoder decodeObject];
		[decoder decodeValueOfObjCType:@encode(unsigned int) at:&flags];
	}
	
	return self;
}

@end
