//
//  NSThread+Naming.h
//  ScriptSync
//
//  Created by Adam Preble on 4/14/11.
//  Copyright 2011 Nexidia, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSThread (Naming)
+ (void)__setCurrentThreadName:(NSString *)name;
+ (void)__updateCurrentThreadName;
@end





@interface ChatterThread : NSThread
@end





@interface NGThreadBlock : NSObject
{
@public
	void (^mBlock)();
}
@end





@interface NSThread (BlocksAdditions)
- (void)performBlock:(void (^)())block;
- (void)performBlock:(void (^)())block waitUntilDone:(BOOL)wait;
- (void)performAfterDelay:(NSTimeInterval)delay block:(void (^)())block;
+ (void)performBlockInBackground:(void (^)())block;
+ (NSThread *)detachNewThreadBlock:(void (^)())block;
- (id)initWithBlock:(void (^)())block;
@end
