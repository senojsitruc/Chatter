//
//  ColloquyImporter.h
//  Chatter
//
//  Created by Jones Curtis on 2011.07.06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceImporter.h"

@interface ColloquyImporter : NSObject <ServiceImporter, NSXMLParserDelegate>
{
@private
	/* configuration */
	ServiceImporterMessageCallback mHandler;
	Class<ServiceImporterMessage> mMessageClass;
	
	/* data */
	NSMutableString *mXmlStr;
	NSString *mSender;
	NSString *mMessage;
	NSString *mTimestamp;
	NSString *mEvent;
	
	/* parsing state */
	BOOL mInLog;
	BOOL mInEnvelope;
	BOOL mInSender;
	BOOL mInMessage;
	BOOL mInSpan;
	BOOL mInEvent;
	BOOL mInWho;
	BOOL mInReason;
}

@end
