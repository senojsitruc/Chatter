//
//  Stemmer.h
//  Chatter
//
//  Created by Jones Curtis on 2011.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stemmer : NSObject
+ (NSArray *)stemsForWords:(NSString *)words;
@end
