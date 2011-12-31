//
//  InstantMessage.h
//  Logtastic
//
//  Created by Ladd Van Tol on Fri Mar 28 2003.
//  Copyright (c) 2003 Spiny. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Presentity;

@interface InstantMessage : NSObject <NSCoding>
{
	Presentity *sender;
	NSDate *date;
	NSAttributedString *text;
	unsigned int flags; 
}

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

@property (readonly) Presentity *sender;
@property (readonly) NSDate *date;
@property (readonly) NSAttributedString *text;
@property (readonly) unsigned int flags;

@end
