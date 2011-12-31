//
//  MessageView.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
	MessageViewTypeTop,
	MessageViewTypeMiddle,
	MessageViewTypeBottom,
	MessageViewTypeWhole
} MessageViewPositionType;

@class ChatterAccount;
@class ChatterMessage;

@interface MessageView : NSView
{
@private
	/* interface */
	NSTextField *mMessageTxt;
	NSImageView *mIconImg;
	NSTableView *mTableView;
	
	/* data */
	ChatterAccount *mAccount;
	ChatterMessage *mMessage;
	MessageViewPositionType mPositionType;
	CGFloat mViewWidth;
	CGFloat mViewHeight;
	CGColorRef mBubbleColor;
	
	/* configuration */
	BOOL mEnableViewConversation;
	NSUInteger tableRowIndex;
}

@property (readonly) ChatterMessage *message;
@property (readonly) NSTextField *messageTxt;
@property (readwrite, assign) MessageViewPositionType positionType;
@property (readwrite, assign) BOOL enableViewConversation;
@property (readwrite, assign) NSTableView *tableView;
@property (readwrite, assign) NSUInteger tableRowIndex;

- (void)configureWithMessage:(ChatterMessage *)message;
- (void)setBubbleColor:(CGColorRef)bubbleColor;

@end
