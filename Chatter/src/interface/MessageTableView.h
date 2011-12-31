//
//  MessageTableView.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@class MessageTableController;

@interface MessageTableView : NSTableView
{
@private
	IBOutlet MessageTableController *mController;
}

@end
