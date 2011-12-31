//
//  StatusbarView.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatusbarView : NSView
{
	IBOutlet NSTextField *mStatusTxt;
	IBOutlet NSTextField *mProgressTxt;
	IBOutlet NSProgressIndicator *mProgressPrg;
}

@end
