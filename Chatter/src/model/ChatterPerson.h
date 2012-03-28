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

@property (weak, readonly) NSString *name;
@property (readwrite, strong) NSImage *image;
@property (readwrite, strong) NSString *firstName;
@property (readwrite, strong) NSString *lastName;
@property (readwrite, strong) NSString *addressBookUid;

+ (id)person;

@end
