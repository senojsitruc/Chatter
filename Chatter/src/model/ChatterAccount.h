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

@property (readwrite, strong) NSImage *image;
@property (readwrite, assign) NSUInteger personId;
@property (readwrite, strong) NSString *screenname;
@property (readwrite, strong) NSString *iconName;

@property (readwrite, weak) ChatterPerson *person;

+ (id)account;

@end
