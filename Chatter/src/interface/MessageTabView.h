//
//  MessageTabView.h
//  Chatter
//
//  Created by Jones Curtis on 2011.07.18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MessageTabView;

typedef void (^MessageTabViewPressed) (MessageTabView*);

@interface MessageTabView : NSView
{
@private
	/* interface */
	IBOutlet NSTextField *mLabel;
	
	/* state */
	BOOL mIsSelected;
	MessageTabViewPressed mHandler;
}

@property (readwrite, assign) BOOL isSelected;
@property (readwrite, assign) MessageTabViewPressed handler;

@end
