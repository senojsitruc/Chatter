//
//  NSString+CZAdditions.m
//  ScriptSync
//
//  Created by Adam Preble on 9/17/10.
//  Copyright 2010 Nexidia, Inc. All rights reserved.
//

#import "NSString+Additions.h"
#import <stdio.h>
#import <stdlib.h>
#import <string.h>

@implementation NSString (Additions)

/**
 *
 *
 */
+ (NSString *)stringWithSpaces:(NSUInteger)spaces
{
	char *cstring = NULL;
	NSString *string = nil;
	
	if (NULL == (cstring = malloc(spaces+1)))
		return nil;
	
	memset(cstring, ' ', spaces+1);
	cstring[spaces] = '\0';
	
	string = [NSString stringWithCString:cstring encoding:NSUTF8StringEncoding];
	
	free(cstring);
	
	return string;
}

/**
 *
 *
 */
- (NSString *)loggable
{
	NSString *output = self;
	
	output = [output stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
	output = [output stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
	
	return output;
}

/**
 *
 *
 */
+ (NSString *)stringWithCString:(const char *)_bytes length:(NSInteger)length encoding:(NSStringEncoding)encoding
{
	if (length == 0)
		return @"";
	else if (_bytes == NULL)
		return @"";
	else if (length < 0)
		length = strlen(_bytes);
	
	char *bytes = malloc(length+1);
	
	if (bytes == NULL)
		return nil;
	
	memcpy(bytes, _bytes, length);
	bytes[length] = '\0';
	
	NSString *byteStr = [NSString stringWithCString:bytes encoding:NSUTF8StringEncoding];
	
	free(bytes);
	
	return byteStr;
}

/**
 *
 *
 */
- (NSString *)stringByTrimmingLeadingWhitespace
{
	return [self stringByTrimmingLeadingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/**
 *
 *
 */
- (NSString *)stringByTrimmingTrailingWhitespace
{
	return [self stringByTrimmingTrailingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/**
 *
 *
 */
- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet
{
	NSRange range = [self rangeOfCharacterFromSet:characterSet];
	
	if (range.location == 0 && range.length != 0)
		return [self substringFromIndex:range.length];
	else
		return self;
}

/**
 *
 *
 */
- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet
{
	NSRange range = [self rangeOfCharacterFromSet:characterSet options:NSBackwardsSearch range:NSMakeRange(0,[self length])];
	
	if (range.location != NSNotFound && range.location + range.length == [self length])
		return [self substringToIndex:range.location];
	else
		return self;
}

@end
