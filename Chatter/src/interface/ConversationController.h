//
//  ConversationController.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ChatterMessage;
@class ChatterSession;

@interface ConversationController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>
{
@private
	/* interface */
	IBOutlet NSWindow *mWindow;
	IBOutlet NSTableView *mTableView;
	
	/* data */
	NSArray *mData;
	ChatterSession *mSession;
	
	/* bubbles */
	CGColorRef mBubbleColors[10];
	NSUInteger mBubbleIndex;
	NSUInteger mBubbleCount;
	CGColorSpaceRef mBubbleSpace;
	NSMutableDictionary *mBubbleColorsByAccountId;
	NSMutableDictionary *mBubbleColorsByPersonId;
}

@property (readwrite, retain) ChatterSession *session;

- (id)initWithMessages:(NSArray *)messages;

- (void)show:(ChatterMessage *)message;
- (void)hide;

@end
