//
//  ConversationController.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConversationController.h"
#import "ChatterAccount.h"
#import "ChatterMessage.h"
#import "ChatterPerson.h"
#import "ChatterSource.h"
#import "ChatterSessionAccount+DBobject.h"
#import "MessageView.h"
#import "ChatterAppDelegate.h"
#import "ChatterObjectCache.h"

@implementation ConversationController

@dynamic session;





#pragma mark - Structors

/**
 *
 *
 */
- (void)awakeFromNib
{
	[self.window setRestorable:FALSE];
	
	mBubbleSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	mBubbleIndex = 0;
	mBubbleCount = 0;
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){0.914, 0.82, 0.18, 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){0.72, 0.7578, 0.789, 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0x21/256., (float)0xBF/256., (float)0x41/256., 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0xBF/256., (float)0x4C/256., (float)0xA9/256., 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0x30/256., (float)0x77/256., (float)0xBF/256., 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0x06/256., (float)0xB5/256., (float)0xBF/256., 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0xBF/256., (float)0xBE/256., (float)0x88/256., 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0xBF/256., (float)0x00/256., (float)0x00/256., 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0xFF/256., (float)0x70/256., (float)0xDB/256., 1.0});
	mBubbleColors[mBubbleCount++] = CGColorCreate(mBubbleSpace, (CGFloat[]){(float)0xCC/256., (float)0xFF/256., (float)0x50/256., 1.0});
	mBubbleColorsByAccountId = [[NSMutableDictionary alloc] init];
	mBubbleColorsByPersonId = [[NSMutableDictionary alloc] init];
}

/**
 *
 *
 */
- (id)initWithMessages:(NSArray *)messages
{
	self = [super initWithWindowNibName:@"ConversationController"];
	
	if (self) {
		mData = [messages sortedArrayUsingComparator:(^ NSComparisonResult (id obj1, id obj2) {
			return [((ChatterMessage *)obj1).timestampStr compare:((ChatterMessage *)obj2).timestampStr];
		})];
		
		[[[self self] window] contentView];
	}
	
	return self;
}





#pragma mark - Accessors

/**
 *
 *
 */
- (void)show:(ChatterMessage *)cmessage
{
	[mWindow makeKeyAndOrderFront:self];
	
	NSInteger row = [mData indexOfObject:cmessage];
	
	if (row >= 0)
		[mTableView scrollRowToVisible:row];
}

/**
 *
 *
 */
- (void)hide
{
	[mWindow close];
}

/**
 *
 *
 */
- (ChatterSession *)session
{
	return mSession;
}

/**
 *
 *
 */
- (void)setSession:(ChatterSession *)csession
{
	if (mSession == csession)
		return;
	
	ChatterObjectCache *cache = [ChatterObjectCache sharedInstance];
	NSMutableIndexSet *accountIds = [[NSMutableIndexSet alloc] init];
	NSMutableString *windowTitle = [[NSMutableString alloc] init];
	__block NSUInteger accountCount = 0;
	
	mSession = csession;
	
	[windowTitle appendString:@"Conversation with "];
	
	[ChatterSessionAccount dbobjectSelectAccountIDsForSession:mSession withHandler:(^ BOOL (NSUInteger accountId) {
		[accountIds addIndex:accountId];
		return TRUE;
	})];
	
	[accountIds enumerateIndexesUsingBlock:(^ (NSUInteger accountId, BOOL *stop) {
		ChatterAccount *caccount = [cache accountForId:accountId];
		ChatterPerson *cperson = caccount.person;
		
		if (cperson != nil)
			[windowTitle appendString:cperson.name];
		else
			[windowTitle appendString:caccount.screenname];
		
		if (accountCount < [accountIds count] - 1)
			[windowTitle appendString:@", "];
		
		accountCount += 1;
	})];
	
	[[self window] setTitle:windowTitle];
	
}





#pragma mark - NSTableViewDataSource

/**
 *
 *
 */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [mData count];
}

/**
 *
 *
 */
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return [mData objectAtIndex:rowIndex];
}





#pragma mark - NSTableViewDelegate

/**
 *
 *
 */
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	return FALSE;
}

/**
 *
 *
 */
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if (row >= [mData count]) {
		NSLog(@"%s.. problem!", __PRETTY_FUNCTION__);
		return nil;
	}
	
	ChatterMessage *cmessage = [mData objectAtIndex:row];
	MessageView *view = [tableView makeViewWithIdentifier:@"MessageView" owner:self];
	CGColorRef bubbleColor = NULL;
	
	if (NULL == (bubbleColor = (__bridge CGColorRef)[mBubbleColorsByAccountId objectForKey:[NSNumber numberWithInteger:cmessage.accountId]]))
		bubbleColor = (__bridge CGColorRef)[mBubbleColorsByAccountId objectForKey:[NSNumber numberWithInteger:cmessage.account.personId]];
	
	if (view == nil) {
		view = [[MessageView alloc] initWithFrame:NSMakeRect(0., 0., [tableView frame].size.width, 0.)];
		view.identifier = @"MessageView";
	}
	
	// determine whether the message on this row is part of a group of messages sent by the same
	// account/person by looking at the messages on the previous and next rows. this information is
	// used to determine how to draw the messages.
	{
		BOOL isTop = TRUE;
		BOOL isBottom = TRUE;
		ChatterMessage *prevMessage=nil, *nextMessage=nil;
		ChatterPerson *cperson=nil, *nextPerson=nil, *prevPerson=nil;
		ChatterAccount *caccount=nil, *nextAccount=nil, *prevAccount=nil;
		
		if (row > 0) {
			NSObject *prevObject = [mData objectAtIndex:row - 1];
			
			if ([prevObject isKindOfClass:[ChatterMessage class]]) {
				prevMessage = (ChatterMessage *)prevObject;
				
				if (prevMessage.accountId == cmessage.accountId) {
					if (!bubbleColor)
						bubbleColor = (__bridge CGColorRef)[mBubbleColorsByAccountId objectForKey:[NSNumber numberWithInteger:cmessage.accountId]];
					isTop = FALSE;
				}
				else {
					if ((caccount = cmessage.account) && (prevAccount = prevMessage.account) == caccount) {
						if (!bubbleColor)
							bubbleColor = (__bridge CGColorRef)[mBubbleColorsByAccountId objectForKey:[NSNumber numberWithInteger:prevMessage.accountId]];
						isTop = FALSE;
					}
					else if ((cperson = caccount.person) && (prevPerson = prevAccount.person) == cperson) {
						if (!bubbleColor)
							bubbleColor = (__bridge CGColorRef)[mBubbleColorsByPersonId objectForKey:[NSNumber numberWithInteger:prevPerson.databaseId]];
						isTop = FALSE;
					}
				}
			}
		}
		
		if (row < [mData count] - 1) {
			NSObject *nextObject = [mData objectAtIndex:row + 1];
			
			if ([nextObject isKindOfClass:[ChatterMessage class]]) {
				nextMessage = (ChatterMessage *)nextObject;
				
				if (nextMessage.accountId == cmessage.accountId) {
					if (!bubbleColor)
						bubbleColor = (__bridge CGColorRef)[mBubbleColorsByAccountId objectForKey:[NSNumber numberWithInteger:cmessage.accountId]];
					isBottom = FALSE;
				}
				else {
					if ((caccount = cmessage.account) && (nextAccount = nextMessage.account) == caccount) {
						if (!bubbleColor)
							bubbleColor = (__bridge CGColorRef)[mBubbleColorsByAccountId objectForKey:[NSNumber numberWithInteger:nextMessage.accountId]];
						isBottom = FALSE;
					}
					else if ((cperson = caccount.person) && (nextPerson = nextAccount.person) == cperson) {
						if (!bubbleColor)
							bubbleColor = (__bridge CGColorRef)[mBubbleColorsByPersonId objectForKey:[NSNumber numberWithInteger:nextPerson.databaseId]];
						isBottom = FALSE;
					}
				}
			}
		}
		
		{
			if (bubbleColor == NULL)
				bubbleColor = mBubbleColors[(mBubbleIndex++ % mBubbleCount)];
			
			if (cmessage.accountId != 0)
				[mBubbleColorsByAccountId setObject:(__bridge NSObject *)bubbleColor forKey:[NSNumber numberWithInteger:cmessage.accountId]];
			
			if (cmessage.account.personId != 0)
				[mBubbleColorsByPersonId setObject:(__bridge NSObject *)bubbleColor forKey:[NSNumber numberWithInteger:cmessage.account.personId]];
		}
		
		view.tableView = tableView;
		view.tableRowIndex = row;
		view.enableViewConversation = TRUE;
		
		if (isTop && isBottom)
			view.positionType = MessageViewTypeWhole;
		else if (isTop)
			view.positionType = MessageViewTypeTop;
		else if (isBottom)
			view.positionType = MessageViewTypeBottom;
		else
			view.positionType = MessageViewTypeMiddle;
	}
	
	[view configureWithMessage:cmessage];
	[view setBubbleColor:bubbleColor];
	
	return view;
}

/**
 *
 *
 */
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	if (row >= [mData count]) {
		NSLog(@"%s.. problem!", __PRETTY_FUNCTION__);
		return 0.;
	}
	
	if ([mData count] == 0)
		return 40.;
	
	MessageView *view = (MessageView *)[self tableView:tableView viewForTableColumn:nil row:row];
	
	if (view == nil)
		return 40.;
	
	return view.frame.size.height + view.frame.origin.y;
}





#pragma mark - NSWindowDelegate

/**
 *
 *
 */
- (void)windowWillClose:(NSNotification *)notification
{
	[[ChatterAppDelegate appDelegate] doActionRemoveConversation:self];
}

@end
