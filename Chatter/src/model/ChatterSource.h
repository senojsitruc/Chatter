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

@property (readwrite, retain) NSString *service;
@property (readwrite, retain) NSString *filePath;
@property (readwrite, retain) NSDate *timestamp;
@property (readwrite, retain) NSString *timestampStr;
@property (readonly) AliasHandle aliasHandle;

+ (id)source;

@end
