//
//  AdiumImporter.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceImporter.h"

@interface AdiumImporter : NSObject <ServiceImporter, NSXMLParserDelegate>
{
@private
	/* configuration */
	ServiceImporterMessageCallback mHandler;
	Class<ServiceImporterMessage> mMessageClass;
	
	/* data */
	NSMutableString *mMessageStr;
	NSString *mSender;
	NSString *mMessageSender;
	NSString *mMessageTime;
	NSString *mServiceName;
	
	/* parsing state */
	BOOL mInChat;
	BOOL mInEvent;
	BOOL mInMessage;
}

@end
