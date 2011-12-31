//
//  Coder.h
//  Ferret
//
//  Created by Curtis Jones on 2009.03.12.
//  Copyright 2009 Nexidia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/time.h>

@interface Coder : NSObject
{
	
}

+ (int)base64encode:(unsigned char *)input insize:(int)insize output:(unsigned char *)output linesize:(int)linesize linebreak:(char *)linebreak;

+ (NSString *)urlEncode:(NSString *)string;
+ (NSString *)urlDecode:(NSString *)string;
+ (NSString *)pathUrlEncode:(NSString *)string;
+ (NSString *)plusUrlEncode:(NSString *)string;

+ (NSString *)md5:(NSString *)input;
+ (void)md5:(NSString *)input output:(void *)output;
+ (NSString *)hash:(NSString *)input;
+ (NSString *)hashFile:(NSString *)filePath;

+ (void)hexdump:(const uint8_t *)buf length:(int)len;

+ (NSString *)durationInMillisecondsToTime:(int64_t)duration;
+ (NSString *)durationFrom:(struct timeval)tv1 until:(struct timeval)tv2;

+ (NSString *)humanReadableFileSize:(uint64_t)fileSize;

@end
