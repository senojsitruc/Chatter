//
//  ChatterSetting.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterObject.h"

@interface ChatterSetting : ChatterObject
{
@protected
	NSString *mName;
	NSString *mValue;
}

@property (readwrite, retain) NSString *name;
@property (readwrite, retain) NSString *valueString;
@property (readwrite, assign) NSInteger valueInteger;

+ (id)setting;

@end
