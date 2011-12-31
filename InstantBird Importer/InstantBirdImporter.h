//
//  InstantBirdImporter.h
//  Chatter
//
//  Created by Jones Curtis on 2011.07.03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceImporter.h"

@interface InstantBirdImporter : NSObject <ServiceImporter>
{
@private
	/* data */
	NSString *mFilePath;
	NSDateComponents *mBaseTimestamp;
	NSCalendar *mBaseCalendar;
}

@end
