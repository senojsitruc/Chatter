//
//  ChatterPerson.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterObject.h"

@interface ChatterPerson : ChatterObject
{
@private
	/* data */
	NSString *mFirstName;
	NSString *mLastName;
	NSString *mAddressBookUid;
	
	/* cache */
	NSImage *mImage;
	NSMutableString *mFullName;
}

@property (readonly) NSString *name;
@property (readwrite, retain) NSImage *image;
@property (readwrite, retain) NSString *firstName;
@property (readwrite, retain) NSString *lastName;
@property (readwrite, retain) NSString *addressBookUid;

+ (id)person;

@end
