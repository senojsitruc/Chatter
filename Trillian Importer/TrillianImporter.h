//
//  TrillianImporter.h
//  Chatter
//
//  Created by Jones Curtis on 2011.07.03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceImporter.h"

@interface TrillianImporter : NSObject <ServiceImporter, NSXMLParserDelegate>
{
@private
	/* configuration */
	ServiceImporterMessageCallback mHandler;
	Class<ServiceImporterMessage> mMessageClass;
	
	/* data */
	NSString *mServiceName;
	
	/* parsing state */
	BOOL mInChat;
}

+ (BOOL)canHandleFilePath:(NSString *)filePath;

@end
