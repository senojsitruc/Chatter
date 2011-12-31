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
	ChatterSource *mSource;
}

@property (readwrite, assign) NSUInteger sourceId;
@property (readwrite, retain) NSString *name;
@property (readwrite, retain) NSDate *timestamp;
@property (readwrite, retain) NSString *timestampStr;
@property (readwrite, assign) ChatterSource *source;

+ (id)session;

@end
