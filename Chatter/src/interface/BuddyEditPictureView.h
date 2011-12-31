//
//  BuddyEditPictureView.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface BuddyEditPictureView : NSImageView
{
@private
	NSString *mImageFilePath;
}

@property (readwrite, retain) NSString *imageFilePath;

@end
