//
//  InstantBirdImporter.m
//  Chatter
//
//  Created by Jones Curtis on 2011.07.03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InstantBirdImporter.h"
#import "ServiceStuff.h"
#import "NSString+Additions.h"

@interface InstantBirdImporter (PrivateMethods)
+ (NSString *)instantBirdDateToStandard:(NSString *)ibDate;
- (BOOL)importData:(NSData *)data withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler;
@end

@implementation InstantBirdImporter

+ (NSString *)name
{
	return @"InstantBird";
}

+ (NSArray *)supportedContentTypes
{
	return nil;
}

+ (NSArray *)supportedTypeCodes
{
	return nil;
}

+ (NSArray *)supportedKinds
{
	return nil;
}

+ (NSArray *)supportedFileExtensions
{
	return nil;
}

+ (NSArray *)supportedSearchPaths
{
	return [NSArray arrayWithObjects:@"~/Library/Application Support/Instantbird/Profiles/", nil];
}

/**
 * Sun Jul  3 18:25:53 2011 -> 2011-06-26 01:30:58 -0400
 * Sat 09 Jul 2011 09:11:55 AM EDT -> 2011-07-09 09:11:55 -0400
 */
+ (NSString *)instantBirdDateToStandard:(NSString *)ibDate
{
	// Sun Jul  3 18:25:53 2011 -> 2011-06-26 01:30:58 -0400
	if ([ibDate length] == 24) {
		char datestr[26] = { 0 };
		
		memcpy(datestr, [ibDate cStringUsingEncoding:NSUTF8StringEncoding], 25);
		
		// Sun Jul  3 18:25:53 2011 -> 2011Jul  3 18:25:53 2011
		datestr[0] = datestr[20];
		datestr[1] = datestr[21];
		datestr[2] = datestr[22];
		datestr[3] = datestr[23];
		
		// 2011Jul  3 18:25:53 2011 -> 2011-07  3 18:25:53 2011
		if (0 == memcmp(datestr+4, "Jan", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '1'; }
		else if (0 == memcmp(datestr+4, "Feb", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '2'; }
		else if (0 == memcmp(datestr+4, "Mar", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '3'; }
		else if (0 == memcmp(datestr+4, "Apr", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '4'; }
		else if (0 == memcmp(datestr+4, "May", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '5'; }
		else if (0 == memcmp(datestr+4, "Jun", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '6'; }
		else if (0 == memcmp(datestr+4, "Jul", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '7'; }
		else if (0 == memcmp(datestr+4, "Aug", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '8'; }
		else if (0 == memcmp(datestr+4, "Sep", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '9'; }
		else if (0 == memcmp(datestr+4, "Oct", 3)) { datestr[4] = '-'; datestr[5] = '1'; datestr[6] = '0'; }
		else if (0 == memcmp(datestr+4, "Nov", 3)) { datestr[4] = '-'; datestr[5] = '1'; datestr[6] = '1'; }
		else if (0 == memcmp(datestr+4, "Dec", 3)) { datestr[4] = '-'; datestr[5] = '1'; datestr[6] = '2'; }
		
		// 2011-07  3 18:25:53 2011 -> 2011-07- 3 18:25:53 2011
		datestr[7] = '-';
		
		// 2011-07- 3 18:25:53 2011 -> 2011-07-03 18:25:53 2011
		if (datestr[8] == ' ')
			datestr[8] = '0';
		
		NSInteger seconds = [[NSTimeZone timeZoneWithAbbreviation:[ibDate substringWithRange:NSMakeRange(28,3)]] secondsFromGMT];
		NSInteger hours = (seconds / 3600);
		NSInteger minutes = (seconds % 3600) / 60;
		
		// set the "+" or "-" for the timezone offset
		if (seconds < 0) {
			datestr[20] = '-';
			hours *= -1;
		}
		else
			datestr[20] = '+';
		
		datestr[21] = (hours / 10);
		datestr[22] = (hours % 10);
		datestr[23] = (minutes / 10);
		datestr[24] = (minutes % 10);
		datestr[25] = '\0';
		
		return [NSString stringWithCString:datestr encoding:NSUTF8StringEncoding];
	}
	
	// Sat 09 Jul 2011 09:11:55 AM EDT -> 2011-07-09 09:11:55 -0400
	else if ([ibDate length] == 31) {
		char datestr[32] = { 0 };
		
		memcpy(datestr, [ibDate cStringUsingEncoding:NSUTF8StringEncoding], 25);
		
		// year: Sat 09 Jul 2011 09:11:55 AM EDT -> 201109 Jul 2011 09:11:55 AM EDT
		datestr[0] = datestr[11];
		datestr[1] = datestr[12];
		datestr[2] = datestr[13];
		datestr[3] = datestr[14];
		
		// day: 201109 Jul 2011 09:11:55 AM EDT -> 201109 Jul 0911 09:11:55 AM EDT
		datestr[11] = datestr[4];
		datestr[12] = datestr[5];
		
		// month: 201109 Jul 0911 09:11:55 AM EDT -> 2011-07Jul 0911 09:11:55 AM EDT
		     if (0 == memcmp(datestr+7, "Jan", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '1'; }
		else if (0 == memcmp(datestr+7, "Feb", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '2'; }
		else if (0 == memcmp(datestr+7, "Mar", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '3'; }
		else if (0 == memcmp(datestr+7, "Apr", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '4'; }
		else if (0 == memcmp(datestr+7, "May", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '5'; }
		else if (0 == memcmp(datestr+7, "Jun", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '6'; }
		else if (0 == memcmp(datestr+7, "Jul", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '7'; }
		else if (0 == memcmp(datestr+7, "Aug", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '8'; }
		else if (0 == memcmp(datestr+7, "Sep", 3)) { datestr[4] = '-'; datestr[5] = '0'; datestr[6] = '9'; }
		else if (0 == memcmp(datestr+7, "Oct", 3)) { datestr[4] = '-'; datestr[5] = '1'; datestr[6] = '0'; }
		else if (0 == memcmp(datestr+7, "Nov", 3)) { datestr[4] = '-'; datestr[5] = '1'; datestr[6] = '1'; }
		else if (0 == memcmp(datestr+7, "Dec", 3)) { datestr[4] = '-'; datestr[5] = '1'; datestr[6] = '2'; }
		
		// day: 2011-07Jul 0911 09:11:55 AM EDT -> 2011-07-09 0911 09:11:55 AM EDT
		datestr[7] = '-';
		datestr[8] = datestr[11];
		datestr[9] = datestr[12];
		
		// time: 2011-07-09 0911 09:11:55 AM EDT -> 2011-07-09 09:11:5511:55 AM EDT
		datestr[11] = datestr[16];
		datestr[12] = datestr[17];
		datestr[13] = datestr[18];
		datestr[14] = datestr[19];
		datestr[15] = datestr[20];
		datestr[16] = datestr[21];
		datestr[17] = datestr[22];
		datestr[18] = datestr[23];
		
		// 12-hour -> 24-hour
		if (datestr[25] == 'P') {
			int hour = (datestr[11] * 10) + datestr[12] + 12;
			
			if (hour == 24)
				hour = 0;
			
			datestr[11] = (hour / 10);
			datestr[12] = (hour % 10);
		}
		
		NSInteger seconds = [[NSTimeZone timeZoneWithAbbreviation:[ibDate substringWithRange:NSMakeRange(28,3)]] secondsFromGMT];
		NSInteger hours = (seconds / 3600);
		NSInteger minutes = (seconds % 3600) / 60;
		
		// set the "+" or "-" for the timezone offset
		if (seconds < 0) {
			datestr[20] = '-';
			hours *= -1;
		}
		else
			datestr[20] = '+';
		
		datestr[21] = (hours / 10);
		datestr[22] = (hours % 10);
		datestr[23] = (minutes / 10);
		datestr[24] = (minutes % 10);
		datestr[25] = '\0';
		
		return [NSString stringWithCString:datestr encoding:NSUTF8StringEncoding];
	}
	
	return nil;
}

/**
 * Conversation with smarterchild at Sun Jul  3 18:25:53 2011 on stygian20 (aim)
 * (18:25:53) stygian20: Yo.
 * (18:25:54) SmarterChild: My brain is retired but watch some cool videos! Send am IM to GossipinGabby and Type VIDEO!
 *
 * Conversation with smarterchild at Sat 09 Jul 2011 10:13:18 AM EDT on stygian20 (aim)
 * (10:13:18 AM) stygian20: Hello there.
 * (10:13:18 AM) SmarterChild: My brain is retired but watch some cool videos! Send am IM to GossipinGabby and Type VIDEO!
 *
 * <html><head><meta http-equiv="content-type" content="text/html; charset=UTF-8"><title>Conversation with cjones@optimus at Sat 09 Jul 2011 09:11:55 AM EDT on inspiron ...
 * <font color="#A82F2F"><font size="2">(09:11:55 AM)</font> <b>Curtis Jones:</b></font> Hello.<br/>
 * <font color="#16569E"><font size="2">(09:12:10 AM)</font> <b>mylocalalias:</b></font> Hello. Hi. How are you? Fine, thank you.<br/>
 * <font color="#16569E"><font size="2">(09:12:21 AM)</font> <b>mylocalalias:</b></font> In the end there can be only one.<br/>
 * <font color="#16569E"><font size="2">(09:12:24 AM)</font> <b>mylocalalias:</b></font> Don't I know it.<br/>
 * <font color="#16569E"><font size="2">(09:12:25 AM)</font> <b>mylocalalias:</b></font> La la la.<br/>
 * </body></html>
 */
+ (BOOL)canHandleFilePath:(NSString *)filePath
{
	BOOL retval = FALSE, isDir;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if (FALSE == [fileManager fileExistsAtPath:filePath isDirectory:&isDir] || isDir)
		goto done_fail;
	
	if (FALSE == [filePath hasSuffix:@".txt"] && FALSE == [filePath hasSuffix:@".html"])
		goto done_fail;
	
	// look for substrings within the first few hundred characters.
	{
		char buf[301] = { 0 };
		int fd = open([filePath cStringUsingEncoding:NSUTF8StringEncoding], O_RDONLY);
		
		if (fd == -1) {
			NSLog(@"%s.. failed to open(), %s", __PRETTY_FUNCTION__, strerror(errno));
			goto done_fail;
		}
		
		ssize_t bytes = read(fd, buf, 300);
		
		if (bytes < 100) {
			close(fd);
			goto done_fail;
		}
		
		NSString *someData = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
		
		if (NSNotFound == [someData rangeOfString:@"Conversation with "].location ||
				NSNotFound == [someData rangeOfString:@" at "].location ||
				NSNotFound == [someData rangeOfString:@" on "].location) {
			close(fd);
			goto done_fail;
		}
		
		close(fd);
		goto done_good;
	}
	
done_good:
	retval = TRUE;
	
done_fail:
	[fileManager release];
	return retval;
}

/**
 * "2011-07-03.182553-0400.txt"
 *
 */
- (BOOL)importFileAtPath:(NSString *)filePath withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler
{
	BOOL isDir = FALSE;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir] || isDir) {
		[fileManager release];
		return FALSE;
	}
	
	[mFilePath release];
	mFilePath = [filePath retain];
	
	// 2011-07-03.182553-0400.txt
	if ([[mFilePath lastPathComponent] length] >= 26) {
		const char *fileName = [[filePath lastPathComponent] UTF8String];
		char year[5]={0}, month[3]={0}, day[3]={0}, tzh[3]={0}, tzm[3]={0};
		NSInteger secondsFromGMT = 0;
		
		year[0] = fileName[0];
		year[1] = fileName[1];
		year[2] = fileName[2];
		year[3] = fileName[3];
		
		month[0] = fileName[5];
		month[1] = fileName[6];
		
		day[0] = fileName[8];
		day[1] = fileName[9];
		
		tzh[0] = fileName[18];
		tzh[1] = fileName[19];
		
		tzm[0] = fileName[20];
		tzm[1] = fileName[21];
		
		secondsFromGMT += strtol(tzh,NULL,10) * 60 * 60;
		secondsFromGMT += strtol(tzm,NULL,10) * 60;
		
		if (fileName[17] == '-')
			secondsFromGMT *= -1;
		
		[mBaseCalendar release];
		mBaseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		mBaseCalendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:secondsFromGMT];
		
		[mBaseTimestamp release];
		mBaseTimestamp = [[NSDateComponents alloc] init];
		mBaseTimestamp.year = strtol(year, NULL, 10);
		mBaseTimestamp.month = strtol(month, NULL, 10);
		mBaseTimestamp.day = strtol(day, NULL, 10);
		mBaseTimestamp.hour = 0;
		mBaseTimestamp.minute = 0;
		mBaseTimestamp.second = 0;
	}
	
	[fileManager release];
	
	return [self importData:[NSData dataWithContentsOfFile:filePath] withMessageClass:messageClass andHandler:handler];
}

/**
 *
 *
 */
- (BOOL)importData:(NSData *)data withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSArray *lines = [[NSString stringWithUTF8String:[data bytes]] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	if ([lines count] == 0)
		goto done;
	
	// Conversation with smarterchild at Sun Jul  3 18:25:53 2011 on stygian20 (aim)
	// <html><head><meta http-equiv="content-type" content="text/html; charset=UTF-8"><title>Conversation with smarterchild at Sat 09 Jul 2011 09:11:55 AM EDT on stygian20 (aim) ...
	if (mBaseTimestamp == nil) {
		NSString *header = [lines objectAtIndex:0];
		NSRange atRange = [header rangeOfString:@" at "];
		NSString *ibDateStr = [header substringWithRange:NSMakeRange(atRange.location+4, 24)];
		NSString *dateStr = [InstantBirdImporter instantBirdDateToStandard:ibDateStr];
		
		mBaseCalendar = [[NSCalendar currentCalendar] retain];
		mBaseTimestamp = [[mBaseCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate dateWithString:dateStr]] retain];
	}
	
	// (18:25:53) stygian20: Yo. This is a test message.
	// (10:13:18 AM) stygian20: Hello there.
	// <font color="#A82F2F"><font size="2">(09:11:55 AM)</font> <b>Curtis Jones:</b></font> Hello.<br/>
	for (NSString *line in lines) {
		NSString *screenName, *messageStr;
		NSRange openParenRange, closeParenRange, colonRange;
		
		if (FALSE == [line hasPrefix:@"("] && FALSE == [line hasPrefix:@"<font"])
			continue;
		
		// parse the timestamp
		{
			openParenRange = [line rangeOfString:@"("];
			closeParenRange = [line rangeOfString:@")"];
			
			if (openParenRange.location == NSNotFound || closeParenRange.location == NSNotFound)
				continue;
			
			NSString *dateStr = [line substringWithRange:NSMakeRange(openParenRange.location+1, closeParenRange.location-openParenRange.location-1)];
			
			// 18:25:53
			if ([dateStr length] == 8) {
				NSInteger hour = [[dateStr substringWithRange:NSMakeRange(0,2)] integerValue];
				NSInteger minute = [[dateStr substringWithRange:NSMakeRange(3,2)] integerValue];
				NSInteger second = [[dateStr substringWithRange:NSMakeRange(6,2)] integerValue];
				
				if (hour < mBaseTimestamp.hour)
					mBaseTimestamp.day += 1;
				
				mBaseTimestamp.hour = hour;
				mBaseTimestamp.minute = minute;
				mBaseTimestamp.second = second;
			}
			
			// 10:13:18 AM
			else if ([dateStr length] == 11) {
				NSInteger hour = [[dateStr substringWithRange:NSMakeRange(0,2)] integerValue];
				NSInteger minute = [[dateStr substringWithRange:NSMakeRange(3,2)] integerValue];
				NSInteger second = [[dateStr substringWithRange:NSMakeRange(6,2)] integerValue];
				
				if ([dateStr hasSuffix:@"PM"])
					hour += 12;
				
				if (hour < mBaseTimestamp.hour)
					mBaseTimestamp.day += 1;
				
				mBaseTimestamp.hour = hour;
				mBaseTimestamp.minute = minute;
				mBaseTimestamp.second = second;
			}
		}
		
		// parse the screen name and message
		{
			// plain text
			if ([line hasPrefix:@"("]) {
				colonRange = [line rangeOfString:@":" options:0 range:NSMakeRange(closeParenRange.location+1, [line length]-closeParenRange.location-1)];
				screenName = [line substringWithRange:NSMakeRange(closeParenRange.location+2, colonRange.location-closeParenRange.location-2)];
				messageStr = [line substringFromIndex:colonRange.location+2];
			}
			// html
			else if ([line hasPrefix:@"<"]) {
				colonRange = [line rangeOfString:@":" options:0 range:NSMakeRange(closeParenRange.location+12, [line length]-closeParenRange.location-12)];
				screenName = [line substringWithRange:NSMakeRange(closeParenRange.location+12, colonRange.location-closeParenRange.location-12)];
				messageStr = [line substringWithRange:NSMakeRange(colonRange.location+13, [line length]-colonRange.location-13-5)];
			}
		}
		
		// create and send the message
		{
			id<ServiceImporterMessage> message = [[(Class)messageClass alloc] init];
			BOOL stop = FALSE;
			
			[message setScreenname:screenName];
			[message setTimestamp:[mBaseCalendar dateFromComponents:mBaseTimestamp]];
			[message setMessage:messageStr];
			
			handler(message, &stop);
			
			if (stop)
				break;
			
			[message release];
		}
	}
	
done:
	[mBaseTimestamp release];
	mBaseTimestamp = nil;
	
	[mBaseCalendar release];
	mBaseCalendar = nil;
	
	[pool release];
	return TRUE;
}

@end
