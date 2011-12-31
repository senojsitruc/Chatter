//
//  ChatterAccount.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatterObject.h"

@class ChatterPerson;

@interface ChatterAccount : ChatterObject
{
@protected
	/* data */
	NSUInteger mPersonId;
	NSString *mScreenName;
	
	/* cache */
	NSImage *mImage;
	NSString *mIconName;
	
	/* weak references */
	ChatterPerson *mPerson;
}

@property (readwrite, retain) NSImage *image;
@property (readwrite, assign) NSUInteger personId;
@property (readwrite, retain) NSString *screenname;
@property (readwrite, retain) NSString *iconName;

@property (readwrite, assign) ChatterPerson *person;

+ (id)account;

@end
