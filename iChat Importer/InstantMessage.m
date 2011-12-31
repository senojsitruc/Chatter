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

- (void)dealloc
{
	[sender release];
	[date release];
	[text release];
	
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	NSLog(@"encodeWithCoder called on %@", [self class]);
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ([decoder allowsKeyedCoding])
	{
		sender = [[decoder decodeObjectForKey:@"Sender"] retain];
		text = [[decoder decodeObjectForKey:@"MessageText"] retain];
		date = [[decoder decodeObjectForKey:@"Time"] retain];
		flags = [decoder decodeInt32ForKey:@"Flags"];
	}
	else
	{
		sender = [[decoder decodeObject] retain];
		date = [[decoder decodeObject] retain];
		text = [[decoder decodeObject] retain];
		[decoder decodeValueOfObjCType:@encode(unsigned int) at:&flags];
	}
	
	return self;
}

@end
