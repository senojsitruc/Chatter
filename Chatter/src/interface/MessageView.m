//
//  MessageView.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageView.h"
#import "Easy.h"
#import "NSColor+Additions.h"
#import "ChatterAccount.h"
#import "ChatterMessage+DBObject.h"
#import "ChatterObjectCache.h"
#import "ChatterSession.h"
#import "ChatterSource.h"
#import "ChatterAppDelegate.h"

#define NSRectToCGRect(r) (((union {NSRect a; CGRect b;})r).b)

@implementation MessageView

@synthesize message = mMessage;
@synthesize messageTxt = mMessageTxt;
@synthesize positionType = mPositionType;
@synthesize enableViewConversation = mEnableViewConversation;
@synthesize tableView = mTableView;
@synthesize tableRowIndex = mTableRowIndex;

/**
 *
 *
 */
- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
		mMessageTxt = [[NSTextField alloc] initWithFrame:NSMakeRect(42., 0., frame.size.width-60., 0.)];
		[mMessageTxt setDrawsBackground:FALSE];
		[mMessageTxt setBackgroundColor:[NSColor clearColor]];
		[mMessageTxt setBezeled:FALSE];
		[mMessageTxt setBordered:FALSE];
		[mMessageTxt setEditable:FALSE];
		
		[self setAutoresizesSubviews:FALSE];
		
		mIconImg = [[NSImageView alloc] initWithFrame:NSMakeRect(0., 0., 32., 32.)];
		
		mViewWidth = 0.;
		mViewHeight = 0.;
		
		mBubbleColor = NULL;
		
		mEnableViewConversation = TRUE;
	}
	
	return self;
}

/**
 *
 *
 */
- (void)dealloc
{
	if (mBubbleColor != NULL)
		CGColorRelease(mBubbleColor);
}





#pragma mark - NSView

/**
 *
 *
 */
- (void)drawRect:(NSRect)dirtyRect
{
	{
		CGFloat oldHeight = self.frame.size.height;
		[self configureWithMessage:mMessage];
		CGFloat newHeight = self.frame.size.height;
		
		if (oldHeight != newHeight)
			[mTableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:mTableRowIndex]];
	}
	
	CGRect currentFrame = NSRectToCGRect(self.frame);
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGFloat strokeWidth = 0.;
	CGFloat bubbleWidth = currentFrame.size.width;
	CGFloat bubbleHeight = currentFrame.size.height;
	CGFloat voffset = 0.;
	CGFloat borderRadius = 10.;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGColorRef borderColor = CGColorCreate(colorSpace, (CGFloat[]){.2, .2, .2, 0.4});
//CGColorRef borderColor = CGColorCreate(colorSpace, (CGFloat[]){.0, .0, .0, 1.0});
//CGColorRef shadowColor = CGColorCreate(colorSpace, (CGFloat[]){.2, .2, .2, 0.3});
	CGColorRef shadowColor = CGColorCreate(colorSpace, (CGFloat[]){0xA7/256., 0xA7/256., 0xA7/256., 0.3});
//CGColorRef shadowColor = CGColorCreate(colorSpace, (CGFloat[]){0., 0., 0., 1.0});
	CGColorRef fillColor = CGColorRetain(mBubbleColor);
	
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextSetLineWidth(context, strokeWidth);
	CGContextSetStrokeColorWithColor(context, borderColor);
	CGContextSetFillColorWithColor(context, fillColor);
	
	// top
	if (MessageViewTypeTop == mPositionType) {
		voffset = 0.;
		
		// bubble
		CGContextSetFillColorWithColor(context, fillColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, strokeWidth + 42.0f, strokeWidth);
		CGContextAddLineToPoint(context, bubbleWidth - strokeWidth - 8.0f, strokeWidth);
		CGContextAddArcToPoint(context, bubbleWidth - strokeWidth - 8.0f, bubbleHeight - strokeWidth - 0.0f, round(bubbleWidth / 2.0f) - strokeWidth + 8.0f, bubbleHeight - strokeWidth - 0.0f, borderRadius - strokeWidth);
		CGContextAddArcToPoint(context, strokeWidth + 42.0f, bubbleHeight - strokeWidth - 0.0f, strokeWidth + 42.0f, strokeWidth + 0.0f, borderRadius - strokeWidth);
		CGContextAddLineToPoint(context, strokeWidth + 42.0f, strokeWidth);
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathFillStroke);
		
		strokeWidth = .5;
		
		// border
		CGContextSetLineJoin(context, kCGLineJoinRound);
		CGContextSetLineWidth(context, strokeWidth);
		CGContextSetStrokeColorWithColor(context, borderColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, bubbleWidth - strokeWidth - 8.0f, strokeWidth);
		CGContextAddArcToPoint(context, bubbleWidth - strokeWidth - 8.0f, bubbleHeight - strokeWidth - 0.0f, round(bubbleWidth / 2.0f) - strokeWidth + 8.0f, bubbleHeight - strokeWidth - 0.0f, borderRadius - strokeWidth);
		CGContextAddArcToPoint(context, strokeWidth + 42.0f, bubbleHeight - strokeWidth - 0.0f, strokeWidth + 42.0f, strokeWidth + 0.0f, borderRadius - strokeWidth);
		CGContextAddLineToPoint(context, strokeWidth + 42.0f, strokeWidth);
		CGContextDrawPath(context, kCGPathStroke);
		
		strokeWidth = .5;
		
		// divider
		CGContextSetLineJoin(context, kCGLineJoinRound);
		CGContextSetLineWidth(context, strokeWidth);
		CGContextSetStrokeColorWithColor(context, borderColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, 50., 6.);
		CGContextAddLineToPoint(context, bubbleWidth - 16., 6.);
		CGContextDrawPath(context, kCGPathStroke);
	}
	
	// middle
	else if (MessageViewTypeMiddle == mPositionType) {
		voffset = 0.;
		
		// bubble
		CGContextSetFillColorWithColor(context, fillColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, strokeWidth + 42.0f, strokeWidth);
		CGContextAddLineToPoint(context, bubbleWidth - strokeWidth - 8.0f, strokeWidth);
		CGContextAddLineToPoint(context, bubbleWidth - strokeWidth - 8.0f, bubbleHeight - strokeWidth);
		CGContextAddLineToPoint(context, strokeWidth + 42.0f, bubbleHeight - strokeWidth);
		CGContextAddLineToPoint(context, strokeWidth + 42.0f, strokeWidth);
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathFillStroke);
		
		strokeWidth = .5;
		
		// border (left)
		CGContextSetLineJoin(context, kCGLineJoinRound);
		CGContextSetLineWidth(context, strokeWidth);
		CGContextSetStrokeColorWithColor(context, borderColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, bubbleWidth - strokeWidth - 8.0f, strokeWidth);
		CGContextAddLineToPoint(context, bubbleWidth - strokeWidth - 8.0f, bubbleHeight - strokeWidth);
		CGContextDrawPath(context, kCGPathStroke);
		
		// border (right)
		CGContextSetLineJoin(context, kCGLineJoinRound);
		CGContextSetLineWidth(context, strokeWidth);
		CGContextSetStrokeColorWithColor(context, borderColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, strokeWidth + 42.0f, bubbleHeight - strokeWidth);
		CGContextAddLineToPoint(context, strokeWidth + 42.0f, strokeWidth);
		CGContextDrawPath(context, kCGPathStroke);
		
		strokeWidth = .5;
		
		// divider
		CGContextSetLineJoin(context, kCGLineJoinRound);
		CGContextSetLineWidth(context, strokeWidth);
		CGContextSetStrokeColorWithColor(context, borderColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, 50., 6.);
		CGContextAddLineToPoint(context, bubbleWidth - 16., 6.);
		CGContextDrawPath(context, kCGPathStroke);
	}
	
	// bottom
	else if (MessageViewTypeBottom == mPositionType) {
		bubbleHeight -= 5;
		voffset = 3.5;
		
		// shadow
		CGContextSetFillColorWithColor(context, shadowColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, borderRadius + strokeWidth + 42.0f, voffset + strokeWidth + 3.0f);
		CGContextAddArcToPoint(context, bubbleWidth - strokeWidth - 8.0f, voffset + strokeWidth + 3.0f, bubbleWidth - strokeWidth - 8.0f, voffset + bubbleHeight - strokeWidth - 0.0f, borderRadius - strokeWidth);
		CGContextAddLineToPoint(context, bubbleWidth - strokeWidth - 8.0f, voffset + bubbleHeight - strokeWidth);
		CGContextAddLineToPoint(context, strokeWidth + 42.0f, voffset + bubbleHeight - strokeWidth);
		CGContextAddArcToPoint(context, strokeWidth + 42.0f, voffset + strokeWidth + 3.0f, bubbleWidth - strokeWidth - 42.0f, voffset + strokeWidth + 0.0f, borderRadius - strokeWidth);
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathFillStroke);
		
		voffset = 5.0;
		
		// bubble
		CGContextSetFillColorWithColor(context, fillColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, borderRadius + strokeWidth + 42.0f, voffset + strokeWidth + 3.0f);
		CGContextAddArcToPoint(context, bubbleWidth - strokeWidth - 8.0f, voffset + strokeWidth + 3.0f, bubbleWidth - strokeWidth - 8.0f, voffset + bubbleHeight - strokeWidth - 0.0f, borderRadius - strokeWidth);
		CGContextAddLineToPoint(context, bubbleWidth - strokeWidth - 8.0f, voffset + bubbleHeight - strokeWidth);
		CGContextAddLineToPoint(context, strokeWidth + 42.0f, voffset + bubbleHeight - strokeWidth);
		CGContextAddArcToPoint(context, strokeWidth + 42.0f, voffset + strokeWidth + 3.0f, bubbleWidth - strokeWidth - 42.0f, voffset + strokeWidth + 0.0f, borderRadius - strokeWidth);
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathFillStroke);
		
		strokeWidth = .5;
		
		// border
		CGContextSetLineJoin(context, kCGLineJoinRound);
		CGContextSetLineWidth(context, strokeWidth);
		CGContextSetStrokeColorWithColor(context, borderColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, strokeWidth + 42.0f, voffset + bubbleHeight - strokeWidth);
		CGContextAddArcToPoint(context, strokeWidth + 42.0f, voffset + strokeWidth + 3.0f, bubbleWidth - strokeWidth - 42.0f, voffset + strokeWidth + 0.0f, borderRadius - strokeWidth);
		CGContextAddArcToPoint(context, bubbleWidth - strokeWidth - 8.0f, voffset + strokeWidth + 3.0f, bubbleWidth - strokeWidth - 8.0f, voffset + bubbleHeight - strokeWidth - 0.0f, borderRadius - strokeWidth);
		CGContextAddLineToPoint(context, bubbleWidth - strokeWidth - 8.0f, voffset + bubbleHeight - strokeWidth);
		CGContextDrawPath(context, kCGPathStroke);
	}
	
	// whole
	else {
		bubbleHeight -= 5;
		voffset = 3.5;
		
		// shadow
		CGContextSetFillColorWithColor(context, shadowColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, strokeWidth + 42.0f, voffset + strokeWidth + 3.0f);
		CGContextAddArcToPoint(context, bubbleWidth - strokeWidth - 8.0f, voffset + strokeWidth + 3.0f, bubbleWidth - strokeWidth - 8.0f, voffset + bubbleHeight - strokeWidth - 0.0f, borderRadius - strokeWidth);
		CGContextAddArcToPoint(context, bubbleWidth - strokeWidth - 8.0f, voffset + bubbleHeight - strokeWidth - 3.0f, round(bubbleWidth / 2.0f) - strokeWidth + 8.0f, voffset + bubbleHeight - strokeWidth - 0.0f, borderRadius - strokeWidth);
		CGContextAddArcToPoint(context, strokeWidth + 42.0f, voffset + bubbleHeight - strokeWidth - 3.0f, strokeWidth + 42.0f, voffset + strokeWidth + 0.0f, borderRadius - strokeWidth);
		CGContextAddArcToPoint(context, strokeWidth + 42.0f, voffset + strokeWidth + 3.0f, bubbleWidth - strokeWidth - 42.0f, voffset + strokeWidth + 0.0f, borderRadius - strokeWidth);
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathFillStroke);
		
		voffset = 5.0;
		
		// bubble
		CGContextSetFillColorWithColor(context, fillColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, strokeWidth + 42.0f, voffset + strokeWidth + 3.0f);
		CGContextAddArcToPoint(context, bubbleWidth - strokeWidth - 8.0f, voffset + strokeWidth + 3.0f, bubbleWidth - strokeWidth - 8.0f, voffset + bubbleHeight - strokeWidth - 0.0f, borderRadius - strokeWidth);
		CGContextAddArcToPoint(context, bubbleWidth - strokeWidth - 8.0f, voffset + bubbleHeight - strokeWidth - 3.0f, round(bubbleWidth / 2.0f) - strokeWidth + 8.0f, voffset + bubbleHeight - strokeWidth - 0.0f, borderRadius - strokeWidth);
		CGContextAddArcToPoint(context, strokeWidth + 42.0f, voffset + bubbleHeight - strokeWidth - 3.0f, strokeWidth + 42.0f, voffset + strokeWidth + 0.0f, borderRadius - strokeWidth);
		CGContextAddArcToPoint(context, strokeWidth + 42.0f, voffset + strokeWidth + 3.0f, bubbleWidth - strokeWidth - 42.0f, voffset + strokeWidth + 0.0f, borderRadius - strokeWidth);
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathFillStroke);
		
		strokeWidth = .5;
		
		// border
		CGContextSetLineJoin(context, kCGLineJoinRound);
		CGContextSetLineWidth(context, strokeWidth);
		CGContextSetStrokeColorWithColor(context, borderColor);
		CGContextClipToRect(context, NSRectToCGRect(dirtyRect));
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, borderRadius + strokeWidth + 42.0f, voffset + strokeWidth + 3.0f);
		CGContextAddArcToPoint(context, bubbleWidth - strokeWidth - 8.0f, voffset + strokeWidth + 3.0f, bubbleWidth - strokeWidth - 8.0f, voffset + bubbleHeight - strokeWidth - 0.0f, borderRadius - strokeWidth);
		CGContextAddArcToPoint(context, bubbleWidth - strokeWidth - 8.0f, voffset + bubbleHeight - strokeWidth - 3.0f, round(bubbleWidth / 2.0f) - strokeWidth + 8.0f, voffset + bubbleHeight - strokeWidth - 0.0f, borderRadius - strokeWidth);
		CGContextAddArcToPoint(context, strokeWidth + 42.0f, voffset + bubbleHeight - strokeWidth - 3.0f, strokeWidth + 42.0f, voffset + strokeWidth + 0.0f, borderRadius - strokeWidth);
		CGContextAddArcToPoint(context, strokeWidth + 42.0f, voffset + strokeWidth + 3.0f, bubbleWidth - strokeWidth - 42.0f, voffset + strokeWidth + 0.0f, borderRadius - strokeWidth);
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathStroke);
	}
	
	// draw the profile image
	{
		mIconImg.bounds = mIconImg.frame;
		[mIconImg drawRect:dirtyRect];
	}
	
	// draw the message text
	{
		mMessageTxt.bounds = mMessageTxt.frame;
		[mMessageTxt drawRect:dirtyRect];
	}
	
	CGColorSpaceRelease(colorSpace);
	CGColorRelease(borderColor);
	CGColorRelease(shadowColor);
	CGColorRelease(fillColor);
}

/**
 *
 *
 */
- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Message Menu"];
	
	// view conversation
	if (mEnableViewConversation) {
		NSMenuItem *item = [menu addItemWithTitle:@"View conversation" action:@selector(doActionViewConversation:) keyEquivalent:@""];
		item.target = self;
	}
	
	// show original file in Finder
	{
		NSMenuItem *item = [menu addItemWithTitle:@"Show original file in Finder" action:@selector(doActionShowFile:) keyEquivalent:@""];
		item.target = self;
	}
	
	/*
	// delete conversation
	{
		NSMenuItem *item = [menu addItemWithTitle:@"Delete conversation" action:@selector(doActionDeleteConversation:) keyEquivalent:@""];
		item.target = self;
	}
	
	// delete message
	{
		NSMenuItem *item = [menu addItemWithTitle:@"Delete message" action:@selector(doActionDeleteMessage:) keyEquivalent:@""];
//	item.target = self;
	}
	*/
	
	return menu;
}





#pragma mark - Accessors

/**
 *
 *
 */
- (void)configureWithMessage:(ChatterMessage *)cmessage
{
	if (mMessage == cmessage && mViewWidth != 0. && mViewWidth == self.frame.size.width)
		return;
	
	if (mMessage != cmessage) {
		mMessage = cmessage;
		mAccount = cmessage.account;
	}
	
	CGFloat textWidth = cmessage.renderWidth;
	CGFloat textHeight = cmessage.renderHeight;
	NSRect viewFrame = self.frame;
	NSRect textFrame = NSMakeRect(42., 0., viewFrame.size.width-60., 0.);
	
	if (textHeight == 0. || textWidth != textFrame.size.width) {
		textHeight = [Easy heightForStringDrawing:cmessage.message withFont:[mMessageTxt font] andWidth:textFrame.size.width-6.];
		
		cmessage.renderWidth = textFrame.size.width;
		cmessage.renderHeight = textHeight;
		mViewWidth = viewFrame.size.width;
		[cmessage dbobjectUpdate];
	}
	
	textFrame.origin.x = 47.;
	textFrame.origin.y = 5.;
	textFrame.size.height = textHeight;
	
	[mMessageTxt setFrame:textFrame];
	[mMessageTxt setBounds:NSMakeRect(0., 0., textFrame.size.width, textFrame.size.height)];
	[mMessageTxt setStringValue:cmessage.message];
	
	if (MessageViewTypeBottom == mPositionType || MessageViewTypeWhole == mPositionType)
		viewFrame.size.height = 15. + textFrame.size.height;
	else
		viewFrame.size.height = 10. + textFrame.size.height;
	
	[self setFrame:viewFrame];
	[self setBounds:NSMakeRect(0., 0., viewFrame.size.width, viewFrame.size.height)];
	
	if (MessageViewTypeTop == mPositionType || MessageViewTypeWhole == mPositionType) {
		mIconImg.image = mAccount.image;
		mIconImg.frame = NSMakeRect(5., viewFrame.size.height-35., 32., 32.);
	}
	else if (MessageViewTypeMiddle == mPositionType)
		mIconImg.image = nil;
	else if (MessageViewTypeBottom == mPositionType)
		mIconImg.image = nil;
}

/**
 *
 *
 */
- (void)setBubbleColor:(CGColorRef)bubbleColor
{
	if (mBubbleColor == bubbleColor)
		return;
	
	if (mBubbleColor != NULL)
		CGColorRelease(mBubbleColor);
	
	mBubbleColor = CGColorRetain(bubbleColor);
}





#pragma mark - Actions

/**
 *
 *
 */
- (void)doActionViewConversation:(id)sender
{
	[[ChatterAppDelegate appDelegate] doActionShowConversation:mMessage.session showMessage:mMessage];
}

/**
 *
 *
 */
- (void)doActionShowFile:(id)sender
{
	ChatterSource *csource = mMessage.source;
	
	if (csource != nil) {
		if (FALSE == [[NSFileManager defaultManager] fileExistsAtPath:csource.filePath]) {
			NSAlert *alert = [[NSAlert alloc] init];
			
			[alert addButtonWithTitle:@"Sorry"];
			[alert setMessageText:@"The source file for this conversation could not be found."];
			[alert setInformativeText:csource.filePath];
			[alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(fileNotFoundAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
		}
		
		[Easy revealFileInFinder:csource.filePath];
	}
}

/**
 *
 *
 */
- (void)fileNotFoundAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[[alert window] orderOut:self];
}

/**
 *
 *
 */
- (void)doActionDeleteConversation:(id)sender
{
	NSAlert *alert = [[NSAlert alloc] init];
	NSUInteger messageCount = [ChatterMessage dbobjectSelectCountForSessionId:mMessage.sessionId];
	
	[alert addButtonWithTitle:@"Delete"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:[NSString stringWithFormat:@"Are you sure you want to delete the %lu messages in this conversation?", messageCount]];
	[alert setInformativeText:@"This action cannot be undone."];
	[alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(deleteConversationAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

/**
 *
 *
 */
- (void)deleteConversationAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	/*
	NSUInteger sourceId;
	ChatterObjectCache *cache;
	
	if (NSAlertFirstButtonReturn == returnCode)
		[ChatterMessage dbobjectDeleteForSourceId:mMessage.sourceId];
	
	sourceId = mMessage.sourceId;
	cache = [ChatterObjectCache sharedInstance];
	
	for (ChatterMessage *cmessage in [cache allMessages]) {
		if (cmessage.sourceId == sourceId)
			[cache removeObject:cmessage];
	}
	
	[Easy postNotification:@"ChatterNotificationBuddySelectionChanged" object:nil];
	[Easy postNotification:@"ChatterNotificationSearchQueryChanged" object:nil];
	*/
	
	[[alert window] orderOut:self];
}

/**
 *
 *
 */
- (void)doActionDeleteMessage:(id)sender
{
	
}

@end
