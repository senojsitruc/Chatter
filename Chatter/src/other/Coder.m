//
//  Coder.m
//  Ferret
//
//  Created by Curtis Jones on 2009.03.12.
//  Copyright 2009 Nexidia. All rights reserved.
//

#import "Coder.h"
#import <CommonCrypto/CommonDigest.h>
#import <errno.h>
#import <fcntl.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <sys/stat.h>
#import <sys/uio.h>
#import <sys/types.h>
#import <unistd.h>

@implementation Coder

static const char cb64[]="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

void base64_encodeblock (unsigned char in[3], unsigned char out[4], int len);
int base64_encode (unsigned char *in, int insize, unsigned char *out, int linesize, char *linebreak);

/**
 *
 *
 */
+ (int)base64encode:(unsigned char *)input insize:(int)insize output:(unsigned char *)output linesize:(int)linesize linebreak:(char *)linebreak
{
	return base64_encode(input, insize, output, linesize, linebreak);
}

/**
 *
 *
 */
+ (NSString *)urlEncode:(NSString *)string
{
	if (string == nil)
		return @"";
	
	return [Coder plusUrlEncode:[string stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
}

/**
 *
 *
 */
+ (NSString *)urlDecode:(NSString *)string
{
	return [string stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}

/**
 *
 *
 */
+ (NSString *)pathUrlEncode:(NSString *)string
{
	string = [string stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	
	return string;
}

/**
 *
 *
 */
+ (NSString *)plusUrlEncode:(NSString *)string
{
	string = [string stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
	string = [string stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
	string = [string stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
	
	return string;
}

/**
 *
 *
 */
+ (NSString *)md5:(NSString *)input
{
	unsigned char hashed[CC_MD5_DIGEST_LENGTH] = { 0 };
	unsigned char base64[CC_MD5_DIGEST_LENGTH*2] = { 0 };
	
	CC_MD5([input cStringUsingEncoding:NSUTF8StringEncoding], (unsigned int)[input lengthOfBytesUsingEncoding:NSUTF8StringEncoding], hashed);
	[Coder base64encode:hashed insize:CC_MD5_DIGEST_LENGTH output:base64 linesize:1000 linebreak:NULL];
	
	return [NSString stringWithUTF8String:(const char *)base64];
}

/**
 *
 *
 */
+ (void)md5:(NSString *)input output:(void *)output
{
	CC_MD5([input cStringUsingEncoding:NSUTF8StringEncoding], (unsigned int)[input lengthOfBytesUsingEncoding:NSUTF8StringEncoding], output);
}

/**
 * /Users/cjones/Movies/Humor = O8gIk-rKZq66hYUMd-i0of8bJn03UCBgSAiLwpkZYGUfQrrHsAUrFHbHC0UZrsYqPUfiscDClVvOlmokh7+Beg==
 *
 */
+ (NSString *)hash:(NSString *)input
{
	unsigned char output[CC_MD5_DIGEST_LENGTH] = { 0 };
	unsigned char hashed[CC_MD5_DIGEST_LENGTH*2] = { 0 };
	
	if (NULL == CC_MD5([input UTF8String], (unsigned int)[input length], output)) {
		NSLog(@"%s.. failed to CC_MD5()", __PRETTY_FUNCTION__);
		return nil;
	}
	
	[Coder base64encode:output insize:CC_MD5_DIGEST_LENGTH output:hashed linesize:1000 linebreak:NULL];
	
	return [NSString stringWithUTF8String:(char*)hashed];
}

/**
 *
 *
 */
+ (NSString *)hashFile:(NSString *)filePath
{
	CC_SHA512_CTX sha;
	void *bytes = NULL;
	FILE *file = NULL;
	size_t size = 0;
	
	unsigned char output[CC_SHA512_DIGEST_LENGTH] = { 0 };
	unsigned char hashed[CC_SHA512_DIGEST_LENGTH*2] = { 0 };
	
	if (NULL == (bytes = malloc(10 * 1024 * 1024))) {
		NSLog(@"%s.. failed to malloc, %s", __PRETTY_FUNCTION__, strerror(errno));
		goto fail;
	}
	
	if (NULL == (file = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "r"))) {
		NSLog(@"%s.. failed to fopen(%@, r), %s", __PRETTY_FUNCTION__, filePath, strerror(errno));
		goto fail;
	}
	
	CC_SHA512_Init(&sha);
	
	while (1) {
		size = fread(bytes, 1, 10*1024*1024, file);
		
		if (size == 0) {
			if (feof(file))
				break;
			else if (ferror(file)) {
				NSLog(@"%s.. failed to fread, %s", __PRETTY_FUNCTION__, strerror(ferror(file)));
				goto fail;
			}
			else
				break;
		}
		
		CC_SHA512_Update(&sha, bytes, (unsigned int)size);
	}
	
	free(bytes);
	fclose(file);
	
	CC_SHA512_Final(output, &sha);
	
	[Coder base64encode:output insize:CC_SHA512_DIGEST_LENGTH output:hashed linesize:1000 linebreak:NULL];
	
	return [NSString stringWithUTF8String:(char*)hashed];
	
fail:
	if (bytes != NULL)
		free(bytes);
	
	if (file != NULL)
		fclose(file);
	
	return nil;
}





/**
 *
 *
 */
void
base64_encodeblock (unsigned char in[3], unsigned char out[4], int len)
{
	out[0] = cb64[ in[0] >> 2 ];
	out[1] = cb64[ ((in[0] & 0x03) << 4) | (len > 1 ? ((in[1] & 0xf0) >> 4) : 0) ];
	out[2] = (unsigned char) (len > 1 ? cb64[ ((in[1] & 0x0f) << 2) | ((in[2] & 0xc0) >> 6) ] : '=');
	out[3] = (unsigned char) (len > 2 ? cb64[ in[2] & 0x3f ] : '=');
}

/**
 *
 *
 */
int
base64_encode (unsigned char *in, int insize, unsigned char *out, int linesize, char *linebreak)
{
	int b=1, i=0, o=0;
	
	if (linebreak == NULL)
		linebreak = "";
	
	for (; i < insize; b++, i+=3, o+=4) {
		base64_encodeblock(in+i, out+o, i <= insize-3 ? 3 : insize-i);
	}
	
	out[o] = '\0';
	
	return o;
}

/**
 *
 *
 */
+ (void)hexdump:(const uint8_t *)buf length:(int)len
{
  int i, j, k;
  
  printf("     -------------------------------------------------------------------------------\n");
  
  for (i = 0; i < len;) {
    printf("     ");
    
    for (j = i; j < i + 8 && j < len; j++)
      printf("%02x ", (unsigned char)buf[j]);
		
    // if at this point we have reached the end of the packet data, we need to
    // pad this last line such that it becomes even with the rest of the lines.
    if (j >= len - 1) {
      for (k = len % 16; k < 8; k++)
        printf("   ");
    }
    
    printf("  ");
    
    for (j = i + 8; j < i + 16 && j < len; j++)
      printf("%02x ", (unsigned char)buf[j]);
		
    // if at this point we have reached the end of the packet data, we need to
    // pad this last line such that it becomes even with the rest of the lines.
    if (j >= len - 1) {
      for (k = 16; k > 8 && k > len % 16; k--)
        printf("   ");
    }
    
    printf("  |  ");
    
    for (j = i; j < i + 16 && j < len; j++) {
      if ((int)buf[j] >= 32 && (int)buf[j] <= 126)
        printf("%c", (unsigned char)buf[j]);
      else
        printf(".");
    }
		
    printf("\n");
    i += 16;
  }
  
  printf("     -------------------------------------------------------------------------------\n");
}

/**
 * hh:mm:ss.sss
 *
 * 60 seconds in a minute
 * 3600 seconds in an hour
 *
 */
+ (NSString *)durationInMillisecondsToTime:(int64_t)duration
{
	NSMutableString *time = [NSMutableString stringWithCapacity:100];
	NSInteger hours=0, minutes=0, seconds=0, millis=0;
	
	if (duration > 3600000L) {
		hours = duration / 3600000L;
		duration -= (hours * 3600000L);
	}
	
	if (duration > 60000L) {
		minutes = duration / 60000L;
		duration -= (minutes * 60000L);
	}
	
	if (duration > 1000L) {
		seconds = duration / 1000L;
		duration -= (seconds * 1000L);
	}
	
	millis = duration;
	
	[time appendFormat:@"%02d:%02d:%02d.%d", hours, minutes, seconds, millis];
	
	return time;
}

/**
 *
 *
 */
+ (NSString *)durationFrom:(struct timeval)tv1 until:(struct timeval)tv2
{
	int64_t beg, end;
	
	beg = (int64_t)tv1.tv_sec * 1000000L;
	beg += tv1.tv_usec;
	
	end = (int64_t)tv2.tv_sec * 1000000L;
	end += tv2.tv_usec;
	
	return [Coder durationInMillisecondsToTime:(end-beg)/1000L];
}

/**
 * bytes
 * KB
 * MB
 * GB
 * TB
 *
 */
+ (NSString *)humanReadableFileSize:(uint64_t)fileSize
{
	uint64_t order = 1024;
	
	// bytes
	if (fileSize < order)
		return [NSString stringWithFormat:@"%llu bytes", fileSize];
	
	// kb
	else if (fileSize < order * order)
		return [NSString stringWithFormat:@"%llu KB", (fileSize/order)];
	
	// mb
	else if (fileSize < order * order * order)
		return [NSString stringWithFormat:@"%llu MB", (fileSize/(order*order))];
	
	// gb
	else if (fileSize < order * order * order * order)
		return [NSString stringWithFormat:@"%llu GB", (fileSize/(order*order*order))];
	
	// tb
	else
		return [NSString stringWithFormat:@"%llu TB", (fileSize/(order*order*order*order))];
}

@end
