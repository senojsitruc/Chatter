//
//  ChatterWord.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatterObject.h"

@interface ChatterWord : ChatterObject
{
@protected
	/* database */
	NSString *mWord;
	
}

@property (readwrite, retain) NSString *word;

+ (id)word;

@end
