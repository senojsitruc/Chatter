//
//  NSThread+Naming.m
//  ScriptSync
//
//  Created by Adam Preble on 4/14/11.
//  Copyright 2011 Nexidia, Inc. All rights reserved.
//

#import "NSThread+Additions.h"
#import "pthread.h"

@implementation NSThread (Naming)

+ (void)__setCurrentThreadName:(NSString *)name
{
	if (name != nil)
		pthread_setname_np([name UTF8String]);
}

+ (void)__updateCurrentThreadName
{
	[NSThread __setCurrentThreadName:[[NSThread currentThread] name]];
}

@end





@implementation ChatterThread

- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[NSThread __updateCurrentThreadName];
	
	[super main];
	[pool drain];
}

@end




@implementation NGThreadBlock

- (void)dealloc
{
	[mBlock release];
	[super dealloc];
}

@end





@implementation NSThread (BlocksAdditions)

- (void)performBlock:(void (^)())block
{
	if ([[NSThread currentThread] isEqual:self])
		block();
	else
		[self performBlock:block waitUntilDone:NO];
}

- (void)performBlock:(void (^)())block waitUntilDone:(BOOL)wait
{
	[NSThread performSelector:@selector(__runBlock:) onThread:self withObject:[block copy] waitUntilDone:wait];
}

- (void)performAfterDelay:(NSTimeInterval)delay block:(void (^)())theBlock
{
	void (^block)() = [theBlock copy];
	[self performBlock:^{
		[NSThread performSelector:@selector(__runBlock:) withObject:block afterDelay:delay];
	}];
}

+ (void)__runBlock:(void (^)())block
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	block();
	[block release];
	[pool release];
}

+ (void)performBlockInBackground:(void (^)())block
{
	[NSThread performSelectorInBackground:@selector(__runBlock:) withObject:[block copy]];
}

+ (NSThread *)detachNewThreadBlock:(void (^)())block
{
	NSThread *thread = [[[NSThread alloc] initWithBlock:block] autorelease];
	[thread start];
	return thread;
}

- (id)initWithBlock:(void (^)())block
{
	NGThreadBlock *threadBlock = [[[NGThreadBlock alloc] init] autorelease];
	
	threadBlock->mBlock = [block copy];
	
	self = [self initWithTarget:self selector:@selector(__runThreadBlock:) object:threadBlock];
	
	if (self)
		[self setStackSize:1024 * 1024 * 8];
	
	return self;
}

- (void)__runThreadBlock:(NGThreadBlock *)threadBlock
{
	threadBlock->mBlock();
}

@end
