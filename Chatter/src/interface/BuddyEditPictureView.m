//
//  BuddyEditPictureView.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BuddyEditPictureView.h"

@implementation BuddyEditPictureView

@synthesize imageFilePath = mImageFilePath;

/**
 *
 *
 */
- (void)setImage:(NSImage *)image
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	[super setImage:image];
}

/**
 *
 *
 */
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	NSPasteboard *pboard = [sender draggingPasteboard];
	
	if ([[pboard types] containsObject:NSFilenamesPboardType]) {
		NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		
		if ([files count] != 0)
			mImageFilePath = [files objectAtIndex:0];
	}
	
	[self.window makeFirstResponder:self];
	
	if (NSDragOperationGeneric == (NSDragOperationGeneric & [sender draggingSourceOperationMask])) {
		[self setFocusRingType:NSFocusRingTypeDefault];
		return NSDragOperationGeneric;
	}
	else
		return NSDragOperationNone;
}

/**
 *
 *
 */
- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self setFocusRingType:NSFocusRingTypeNone];
}

@end
