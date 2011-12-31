//
//  AIMImporter.h
//  Chatter
//
//  Created by Jones Curtis on 2011.07.03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceImporter.h"

typedef enum
{
	AIMFileTypeHtml = 1,
	AIMFileTypeXml = 2
} AIMFileType;

typedef enum
{
	AIMMessageDirectionIncoming = 1,
	AIMMessageDirectionOutgoing = 2
} AIMMessageDirection;

@interface AIMImporter : NSObject <ServiceImporter, NSXMLParserDelegate>
{
@private
	/* configuration */
	ServiceImporterMessageCallback mHandler;
	Class<ServiceImporterMessage> mMessageClass;
	
	/* data */
	NSMutableString *mXmlStr;
	NSString *mFilePath;
	AIMFileType mFileType;
	AIMMessageDirection mDirection;
	NSString *mScreenName;
	NSString *mTimestamp;
	NSString *mServiceName;
	NSString *mMessageStr;
	NSDateComponents *mBaseTimestamp;
	NSCalendar *mBaseCalendar;
	
	/* parsing state - xml */
	BOOL mInChat;
	BOOL mInMessage;
	
	/* parsing state - html */
	BOOL mInHtml;
	BOOL mInBody;
	BOOL mInDivMessage;
	BOOL mInSpanHeader;
	BOOL mInSpanTimestamp;
	BOOL mInSpanBody;
}

@end
