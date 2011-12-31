//
//  CZSaveable.h
//  ScriptSync
//
//  Created by Curtis Jones on 2010.09.24.
//  Copyright 2010 Nexidia, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol CZSaveable <NSObject>

/**
 * Save the underlying data to whatever the appropriate store is.
 */
- (BOOL)save;

@end
