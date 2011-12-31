//
//  VersionChecker.h
//  Chatter
//
//  Created by Jones Curtis on 2011.07.06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VersionChecker : NSObject
{
@private
	
}

+ (id)sharedInstance;

- (void)checkWithHandler:(void (^)(NSString*, NSUInteger, NSError*))handler;

@end
