//
//  SkypeImporter.h
//  Chatter
//
//  Created by Jones Curtis on 2011.07.09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceImporter.h"

@interface SkypeImporter : NSObject <ServiceImporter>
{
	/* data */
	NSString *mSession;
	NSString *mSender;
	NSMutableString *mMessage;
	NSDate *mTimestamp;
}
@end
