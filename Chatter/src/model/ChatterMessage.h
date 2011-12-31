//
//  ChatterMessage.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatterObject.h"
#import "ServiceImporter.h"

@class ChatterAccount;
@class ChatterSession;
@class ChatterSource;

@interface ChatterMessage : ChatterObject <ServiceImporterMessage>
{
@protected
	/* database */
	NSUInteger mAccountId;
	NSUInteger mSourceId;
	NSUInteger mSessionId;
	NSString *mScreenName;
	NSDate *mTimestamp;
	NSString *mTimestampStr;
	NSUInteger mRenderWidth;
	NSUInteger mRenderHeight;
	NSString *mMessage;
	
	/* weak references */
	ChatterAccount *mAccount;
	ChatterSession *mSession;
	ChatterSource *mSource;
	
	/* for importers where a file contain more than one conversation (ie, icq and skype) */
	NSString *mSessionName;
}

@property (readwrite, assign) NSUInteger accountId;
@property (readwrite, assign) NSUInteger sourceId;
@property (readwrite, assign) NSUInteger sessionId;
@property (readwrite, retain) NSString *screenname;
@property (readwrite, retain) NSDate *timestamp;
@property (readwrite, retain) NSString *timestampStr;
@property (readwrite, assign) NSUInteger renderWidth;
@property (readwrite, assign) NSUInteger renderHeight;
@property (readwrite, retain) NSString *message;

@property (readwrite, assign) ChatterAccount *account;
@property (readwrite, assign) ChatterSession *session;
@property (readwrite, assign) ChatterSource *source;

@property (readwrite, retain) NSString *sessionName;

+ (id)message;

@end
