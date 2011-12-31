//
//  NSString+CZAdditions.h
//  ScriptSync
//
//  Created by Adam Preble on 9/17/10.
//  Copyright 2010 Nexidia, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (Additions)

/**
 * Returns a new string with 'n' spaces.
 */
+ (NSString *)stringWithSpaces:(NSUInteger)spaces;

/**
 *
 */
- (NSString *)loggable;

/**
 *
 */
+ (NSString *)stringWithCString:(const char *)_bytes length:(NSInteger)length encoding:(NSStringEncoding)encoding;

/**
 * Trimming leading/trailing characters
 */
- (NSString *)stringByTrimmingLeadingWhitespace;
- (NSString *)stringByTrimmingTrailingWhitespace;
- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;

@end
