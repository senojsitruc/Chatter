//
//  MessageGroupView.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageGroupView.h"
#import "ChatterAccount.h"
#import "ChatterMessage.h"
#import "ChatterObjectCache.h"
#import "ChatterPerson.h"
#import "ChatterSessionAccount+DBObject.h"
#import "Easy.h"

@implementation MessageGroupView

@synthesize isChatGroup = mIsChatGroup;
@synthesize isPersonGroup = mIsPersonGroup;





#pragma mark - Structors

/**
 *
 *
 */
- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
		mDescriptionTxt = [[NSTextField alloc] initWithFrame:NSMakeRect(5., 3., frame.size.width-10., 15.)];
		[mDescriptionTxt setDrawsBackground:FALSE];
		[mDescriptionTxt setBackgroundColor:[NSColor clearColor]];
		[mDescriptionTxt setBezeled:FALSE];
		[mDescriptionTxt setBordered:FALSE];
		[mDescriptionTxt setEditable:FALSE];
		[mDescriptionTxt setSelectable:FALSE];
		[[mDescriptionTxt cell] setLineBreakMode:NSLineBreakByCharWrapping];
		[self addSubview:mDescriptionTxt];
		
		mIsChatGroup = FALSE;
		mIsPersonGroup = FALSE;
	}
	
	return self;
}





#pragma mark - NSView

/**
 *
 *
 */
- (void)drawRect:(NSRect)rect
{
	/*
	CGFloat colors[8] = { 0.894, 0.894, 0.894, 1.0, 0.694, 0.694, 0.694, 1.0 };
	CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
	CGColorSpaceRelease(baseSpace), baseSpace = NULL;
	
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextClearRect(context, NSRectToCGRect(rect));
	CGContextSaveGState(context);
	
	CGPoint endPoint = CGPointMake(CGRectGetMidX(NSRectToCGRect(rect)), CGRectGetMinY(NSRectToCGRect(rect)));
	CGPoint startPoint = CGPointMake(CGRectGetMidX(NSRectToCGRect(rect)), CGRectGetMaxY(NSRectToCGRect(rect)));
	
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	
	CGGradientRelease(gradient), gradient = NULL;
	
	CGContextRestoreGState(context);
	*/
}




#pragma mark - Accessors

/**
 *
 *
 */
- (void)configureWithMessage:(ChatterMessage *)cmessage
{
	if (mMessage == cmessage)
		return;
	
	ChatterObjectCache *cache = [ChatterObjectCache sharedInstance];
	NSMutableString *description = [NSMutableString string];
	
	mMessage = cmessage;
	
	if (mIsChatGroup) {
		NSMutableArray *participants = [[NSMutableArray alloc] init];
		NSUInteger participantsIndex = 0;
		
		[ChatterSessionAccount dbobjectSelectAccountIDsForSession:mMessage.session withHandler:(^ BOOL (NSUInteger accountId) {
			ChatterAccount *caccount = [cache accountForId:accountId];
			ChatterPerson *cperson = caccount.person;
			
			if (cperson != nil)
				[participants addObject:cperson];
			else
				[participants addObject:caccount];
			
			return TRUE;
		})];
		
		[description appendString:@"Chat on "];
		[description appendString:[mMessage.timestampStr substringToIndex:19]];
		[description appendString:@" with "];
		
		for (ChatterObject *participant in participants) {
			if (participantsIndex != 0)
				[description appendString:@", "];
			
			if ([participant isKindOfClass:[ChatterAccount class]])
				[description appendString:((ChatterAccount *)participant).screenname];
			else if ([participant isKindOfClass:[ChatterPerson class]])
				[description appendString:((ChatterPerson *)participant).name];
			
			participantsIndex += 1;
		}
	}
	
	else if (mIsPersonGroup) {
		ChatterAccount *caccount = mMessage.account;
		ChatterPerson *cperson = caccount.person;
		NSString *name;
		
		name = cperson.name;
		
		if (name == nil)
			name = caccount.screenname;
		
		[description appendString:name];
	}
	
	[mDescriptionTxt setStringValue:description];
	
	{
		NSRect viewFrame = self.frame;
		NSRect textFrame = mDescriptionTxt.frame;
		
		textFrame.size.height = [Easy heightForStringDrawing:description withFont:[mDescriptionTxt font] andWidth:textFrame.size.width-6.];
		viewFrame.size.height = textFrame.size.height - 10;
		textFrame.origin.y = 0;
		textFrame.size.height -= 10;
		
		mDescriptionTxt.frame = textFrame;
		self.frame = viewFrame;
		
		/*
		NSLog(@"  viewFrame = ( x=%f, y=%f, w=%f, h=%f )", viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
		NSLog(@"  textFrame = ( x=%f, y=%f, w=%f, h=%f )", textFrame.origin.x, textFrame.origin.y, textFrame.size.width, textFrame.size.height);
		*/
		
	}
}

@end
