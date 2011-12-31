//
//  MessageGroupView.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ChatterMessage;

@interface MessageGroupView : NSView
{
@private
	/* interface */
	NSTextField *mDescriptionTxt;
	
	/* configuration */
	BOOL mIsChatGroup;
	BOOL mIsPersonGroup;
	
	/* data */
	ChatterMessage *mMessage;
}

@property (readwrite, assign) BOOL isChatGroup;
@property (readwrite, assign) BOOL isPersonGroup;

- (void)configureWithMessage:(ChatterMessage *)cmessage;

@end
