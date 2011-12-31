//
//  AboutController.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutController : NSViewController
{
@private
	IBOutlet NSTextView *mAboutTxt;
	IBOutlet NSPanel *mPanel;
	IBOutlet NSTextField *mVersionTxt;
	
	BOOL mIsShowingChangelog;
}

@end
