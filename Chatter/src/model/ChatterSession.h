//
//  ChatterSession.h
//  Chatter
//
//  Created by Jones Curtis on 2011.07.09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterObject.h"

@class ChatterSource;

@interface ChatterSession : ChatterObject
{
@private
	/* data */
	NSUInteger mSourceId;
	NSString *mName;
	NSDate *mTimestamp;
	NSString *mTimestampStr;
	
	/* weak references */
	ChatterSource *__weak mSource;
}

@property (readwrite, assign) NSUInteger sourceId;
@property (readwrite, strong) NSString *name;
@property (readwrite, strong) NSDate *timestamp;
@property (readwrite, strong) NSString *timestampStr;
@property (readwrite, weak) ChatterSource *source;

+ (id)session;

@end
