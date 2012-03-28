//
//  ToolbarSearchItem.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ToolbarSearchItem.h"
#import "Easy.h"

@implementation ToolbarSearchItem

/**
 *
 *
 */
- (id)initWithItemIdentifier:(NSString *)identifier
{
	self = [super initWithItemIdentifier:identifier];
	
	if (self) {
		mSearch = [[NSSearchField alloc] init];
		mSearch.frame = NSMakeRect(0., 0., 200., 19.);
		[mSearch setDelegate:(id<NSTextFieldDelegate>)self];
		[[mSearch cell] setPlaceholderString:@"Search"];
		
		[self setView:mSearch];
		[self setMinSize:NSMakeSize(200., 19.)];
		[self setMaxSize:NSMakeSize(200., 19.)];
	}
	
	return self;
}

/**
 *
 *
 */
- (id)copyWithZone:(NSZone *)zone
{
	ToolbarSearchItem *copy = [[[self class] allocWithZone:zone] init];
	
	return copy;
}

/**
 *
 *
 */
- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[Easy postNotification:@"ChatterNotificationSearchQueryChanged" object:[mSearch stringValue]];
}

@end
