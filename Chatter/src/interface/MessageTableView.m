//
//  MessageTableView.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageTableView.h"
#import "MessageTableController.h"

@implementation MessageTableView

#pragma mark - NSView

/**
 *
 *
 */
- (void)viewWillStartLiveResize
{
	// this call is important so that we can change the size of the table to a minimal set of rows
	// and scroll to the top.
	[mController resize];
	
	[super viewWillStartLiveResize];
}

/**
 *
 *
 */
- (void)viewDidEndLiveResize
{
	[mController resize];
	[super viewDidEndLiveResize];
}

@end
