//
//  ChatterSource.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatterObject.h"

@interface ChatterSource : ChatterObject
{
@protected
	/* database */
	NSString *mService;
	NSString *mFilePath;
	NSDate *mTimestamp;
	NSString *mTimestampStr;
	NSData *mAlias;
}

@property (readwrite, strong) NSString *service;
@property (readwrite, strong) NSString *filePath;
@property (readwrite, strong) NSDate *timestamp;
@property (readwrite, strong) NSString *timestampStr;
@property (readonly) AliasHandle aliasHandle;

+ (id)source;

@end
