//
//  AIMImporter.m
//  Chatter
//
//  Created by Jones Curtis on 2011.07.03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AIMImporter.h"
#import "ServiceStuff.h"
#import "NSString+Additions.h"
#import <errno.h>
#import <fcntl.h>
#import <string.h>

@interface AIMImporter (PrivateMethods)
+ (NSString *)aimDateToStandard:(NSString *)aimDate;
- (BOOL)importData:(NSData *)data withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler;
@end

@implementation AIMImporter

/**
 * 2011-06-26T01.30.58-0400 -> 2011-06-26 01:30:58 -0400
 * 2011-06-26T01:31:01-0400 -> 2011-06-26 01:31:01 -0400
 */
+ (NSString *)aimDateToStandard:(NSString *)aimDate
{
	char datestr[26] = { 0 };
	
	if ([aimDate length] != 24)
		return nil;
	
	memcpy(datestr, [aimDate cStringUsingEncoding:NSUTF8StringEncoding], 25);
	
	datestr[10] = ' ';
	datestr[13] = ':';
	datestr[16] = ':';
	datestr[24] = datestr[23];
	datestr[23] = datestr[22];
	datestr[22] = datestr[21];
	datestr[21] = datestr[20];
	datestr[20] = datestr[19];
	datestr[19] = ' ';
	
	return [NSString stringWithCString:datestr encoding:NSUTF8StringEncoding];
}

/**
 * XML:
 *
 * <?xml version="1.0" encoding="utf-8" standalone="no"?>
 * <chat xmlns="http://purl.org/net/ulf/ns/0.4-02" account="stygian20" remote="gossipingabby" service="AIM">
 *   <message sender="stygian20" time="2011-06-26T01:31:01-0400">
 *     ...
 *   </message
 * </chat>
 *
 *
 * HTML:
 *
 * <?xml version="1.0" encoding="utf-8" standalone="no"?>
 * <html xmlns="http://www.w3.org/1999/xhtml">
 *   <head>
 *     <meta http-equiv="content-type" content="text/html; charset=utf-8" />
 *     <style type="text/css"> ... </style>
 *     <title></title>
 *   </head>
 *   <body id="thebody">
 *     <div>
 *       <div class="aolimmessage">
 *         <span class="aoloutgoingIMheader">stygian20:</span>
 *         <span class="aolinlinetimestamp">(5:43:46 PM)</span>
 *         <span class="aolimbody">
 *           <font face="Helvetica" size="2" style="font-size: 12.000000px">Hello.</font>
 *         </span>
 *         <br />
 *       </div>
 *     </div>
 *   </body>
 * </html>
 */
+ (BOOL)canHandleFilePath:(NSString *)filePath
{
	BOOL retval = FALSE, isDir;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if (FALSE == [fileManager fileExistsAtPath:filePath isDirectory:&isDir] || isDir)
		goto done_fail;
	
	if (FALSE == [filePath hasSuffix:@".html"])
		goto done_fail;
	
	// look for substrings within the first couple hundred characters.
	{
		char buf[301] = { 0 };
		int fd = open([filePath cStringUsingEncoding:NSUTF8StringEncoding], O_RDONLY);
		
		if (fd == -1) {
			NSLog(@"%s.. failed to open(), %s", __PRETTY_FUNCTION__, strerror(errno));
			goto done_fail;
		}
		
		ssize_t bytes = read(fd, buf, 300);
		
		if (bytes < 161) {
			close(fd);
			goto done_fail;
		}
		
		NSString *someData = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
		
		// xml
		if (NSNotFound != [someData rangeOfString:@"<chat "].location &&
				NSNotFound != [someData rangeOfString:@"account="].location &&
				NSNotFound != [someData rangeOfString:@"service=\"AIM\""].location &&
				NSNotFound != [someData rangeOfString:@"<?xml "].location) {
			close(fd);
			goto done_good;
		}
		// html
		else if (NSNotFound != [someData rangeOfString:@"<html"].location &&
						 NSNotFound != [someData rangeOfString:@"<head"].location &&
						 NSNotFound != [someData rangeOfString:@"<style"].location &&
						 NSNotFound != [someData rangeOfString:@"<?xml "].location) {
			close(fd);
			goto done_good;
		}
		
		close(fd);
		goto done_fail;
	}
	
done_good:
	retval = TRUE;
	
done_fail:
	return retval;
}

/**
 *
 *
 */
- (id)init
{
	self = [super init];
	
	if (self) {
		mXmlStr = [[NSMutableString alloc] init];
		mBaseTimestamp = [[NSDateComponents alloc] init];
		mBaseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	}
	
	return self;
}





#pragma mark - ServiceImporter

+ (NSString *)name
{
	return @"AIM";
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
	return [NSArray arrayWithObjects:@"~/Documents/AIM Logs", nil];
}

/**
 * "gossipingabby (2011-06-26T01.30.58-0400).html"
 *
 */
- (BOOL)importFileAtPath:(NSString *)filePath withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler
{
	BOOL isDir = FALSE;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir] || isDir)
		return FALSE;
	
	mFilePath = filePath;
	
	// "gossipingabby (2011-06-26T01.30.58-0400).html" -> "2011-06-26 01:30:58 -0400"
	{
		NSString *fileName = [filePath lastPathComponent];
		NSRange openParen = [fileName rangeOfString:@"(" options:NSBackwardsSearch];
		NSRange closeParen = [fileName rangeOfString:@")" options:NSBackwardsSearch];
		
		if (openParen.location != NSNotFound && closeParen.location != NSNotFound && openParen.location < closeParen.location) {
			NSString *aimDateStr = [fileName substringWithRange:NSMakeRange(openParen.location+1, (closeParen.location-openParen.location-1))];
			NSString *dateStr = [AIMImporter aimDateToStandard:aimDateStr];
			const char *dateBytes = [dateStr cStringUsingEncoding:NSUTF8StringEncoding];
			char tzHour[4]={0}, tzMinute[3]={0};
			
			[mBaseTimestamp setYear:strtol(dateBytes+0, NULL, 10)];
			[mBaseTimestamp setMonth:strtol(dateBytes+5, NULL, 10)];
			[mBaseTimestamp setDay:strtol(dateBytes+8, NULL, 10)];
			[mBaseTimestamp setHour:strtol(dateBytes+11, NULL, 10)];
			[mBaseTimestamp setMinute:strtol(dateBytes+14, NULL, 10)];
			[mBaseTimestamp setSecond:strtol(dateBytes+17, NULL, 10)];
			
			tzHour[0] = dateBytes[20];
			tzHour[1] = dateBytes[21];
			tzHour[2] = dateBytes[22];
			
			tzMinute[0] = dateBytes[23];
			tzMinute[1] = dateBytes[24];
			
			[mBaseTimestamp setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:(strtol(tzHour,NULL,10)*60*60) + (strtol(tzMinute,NULL,10)*60)]];
		}
	}
	
	
	return [self importData:[NSData dataWithContentsOfFile:filePath] withMessageClass:messageClass andHandler:handler];
}

/**
 *
 *
 */
- (BOOL)importData:(NSData *)data withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler
{
	@autoreleasepool {
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
		
		mHandler = handler;
		mMessageClass = messageClass;
		
		// determine whether this is the xml file format or the html file format
		{
			NSString *someData = [NSString stringWithCString:[data bytes] length:MIN([data length], 300) encoding:NSUTF8StringEncoding];
			
			if (NSNotFound != [someData rangeOfString:@"<chat "].location &&
					NSNotFound != [someData rangeOfString:@"account="].location &&
					NSNotFound != [someData rangeOfString:@"service=\"AIM\""].location &&
					NSNotFound != [someData rangeOfString:@"<?xml "].location) {
				mFileType = AIMFileTypeXml;
			}
			// html
			else if (NSNotFound != [someData rangeOfString:@"<html "].location &&
							 NSNotFound != [someData rangeOfString:@"<head"].location &&
							 NSNotFound != [someData rangeOfString:@"<style"].location &&
							 NSNotFound != [someData rangeOfString:@"<?xml "].location) {
				mFileType = AIMFileTypeHtml;
			}
			else
				return FALSE;
		}
		
		[parser setDelegate:self];
		[parser parse];
		
		mHandler = nil;
	}
	
	return TRUE;
}





#pragma mark - NSXMLParserDelegate

/**
 *
 *
 */
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// xml
	mInChat = FALSE;
	mInMessage = FALSE;
	
	// html
	mInHtml = FALSE;
	mInBody = FALSE;
	mInDivMessage = FALSE;
	mInSpanHeader = FALSE;
	mInSpanTimestamp = FALSE;
	mInSpanBody = FALSE;
}

/**
 *
 *
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	
}

/**
 *
 *
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	// xml
	if (AIMFileTypeXml == mFileType) {
		if (mInChat) {
			if (mInMessage) {
				// ...
			}
			else if ([elementName isEqualToString:@"message"]) {
				mScreenName = [attributeDict objectForKey:@"sender"];
				mTimestamp = [AIMImporter aimDateToStandard:[attributeDict objectForKey:@"time"]];
				mInMessage = TRUE;
			}
		}
		else if ([elementName isEqualToString:@"chat"]) {
			mServiceName = [attributeDict objectForKey:@"account"];
			mInChat = TRUE;
		}
	}
	
	// html
	else if (AIMFileTypeHtml == mFileType) {
		if (mInHtml) {
			if (mInBody) {
				if (mInDivMessage) {
					if ([elementName isEqualToString:@"span"]) {
						NSString *c = [attributeDict objectForKey:@"class"];
						
						if ([c isEqualToString:@"aoloutgoingIMheader"] || [c isEqualToString:@"aolincomingIMheader"])
							mInSpanHeader = TRUE;
						else if ([c isEqualToString:@"aolinlinetimestamp"])
							mInSpanTimestamp = TRUE;
						else if ([c isEqualToString:@"aolimbody"])
							mInSpanBody = TRUE;
					}
				}
				else if ([elementName isEqualToString:@"div"] && [[attributeDict objectForKey:@"class"] isEqualToString:@"aolimmessage"])
					mInDivMessage = TRUE;
			}
			else if ([elementName isEqualToString:@"body"])
				mInBody = TRUE;
		}
		else if ([elementName isEqualToString:@"html"])
			mInHtml = TRUE;
	}
}

/**
 *
 *
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	// xml
	if (AIMFileTypeXml == mFileType) {
		if (mInChat) {
			if (mInMessage) {
				if ([elementName isEqualToString:@"message"]) {
					NSString *messageStr = [mXmlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					
					if ([messageStr length] != 0) {
						id<ServiceImporterMessage> message = [[(Class)mMessageClass alloc] init];
						BOOL stop = FALSE;
						
						[message setScreenname:mScreenName];
						[message setTimestampStr:mTimestamp];
						[message setMessage:messageStr];
						
						mHandler(message, &stop);
						
						if (stop)
							[parser abortParsing];
						
						[mXmlStr setString:@""];
					}
					
					mInMessage = FALSE;
				}
				else if ([elementName isEqualToString:@"br"])
					[mXmlStr appendString:@"\n"];
			}
			else if ([elementName isEqualToString:@"chat"]) {
				mInChat = FALSE;
			}
		}
	}
	
	// html
	else if (AIMFileTypeHtml == mFileType) {
		if (mInHtml) {
			if (mInBody) {
				if (mInDivMessage) {
					if ([elementName isEqualToString:@"span"]) {
						if (mInSpanHeader) {
							if ([mXmlStr hasSuffix:@":"])
								mScreenName = [[mXmlStr substringToIndex:[mXmlStr length]-1] lowercaseString];
							else
								mScreenName = [[NSString stringWithString:mXmlStr] lowercaseString];
							[mXmlStr setString:@""];
							mInSpanHeader = FALSE;
						}
						else if (mInSpanTimestamp) {
							mTimestamp = [NSString stringWithString:mXmlStr];
							[mXmlStr setString:@""];
							mInSpanTimestamp = FALSE;
						}
						else if (mInSpanBody) {
							mMessageStr = [mXmlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
							[mXmlStr setString:@""];
							mInSpanBody = FALSE;
						}
					}
					else if ([elementName isEqualToString:@"div"]) {
						id<ServiceImporterMessage> message = [[(Class)mMessageClass alloc] init];
						BOOL stop = FALSE;
						
						// (5:43:47 PM)
						if ([mTimestamp hasPrefix:@"("] && [mTimestamp hasSuffix:@")"]) {
							NSString *wholeStr = [mTimestamp substringWithRange:NSMakeRange(1, [mTimestamp length]-2)];
							NSString *timeStr = [wholeStr substringToIndex:[mTimestamp rangeOfString:@" "].location];
							NSArray *timeParts = [timeStr componentsSeparatedByString:@":"];
							long hour = strtol([[timeParts objectAtIndex:0] cStringUsingEncoding:NSUTF8StringEncoding], NULL, 10);
							long minute = strtol([[timeParts objectAtIndex:1] cStringUsingEncoding:NSUTF8StringEncoding], NULL, 10);
							long second = strtol([[timeParts objectAtIndex:2] cStringUsingEncoding:NSUTF8StringEncoding], NULL, 10);
							
							if ([wholeStr hasSuffix:@"PM"])
								hour += 12;
							
							if (hour < [mBaseTimestamp hour])
								mBaseTimestamp.day = mBaseTimestamp.day + 1;
							
							mBaseTimestamp.hour = hour;
							mBaseTimestamp.minute = minute;
							mBaseTimestamp.second = second;
						}
						
						[message setScreenname:mScreenName];
						[message setTimestamp:[mBaseCalendar dateFromComponents:mBaseTimestamp]];
						[message setMessage:mMessageStr];
						
						mHandler(message, &stop);
						
						if (stop)
							[parser abortParsing];
						
						[mXmlStr setString:@""];
						mInDivMessage = FALSE;
					}
				}
				else if ([elementName isEqualToString:@"body"])
					mInBody = FALSE;
			}
			else if ([elementName isEqualToString:@"html"])
				mInHtml = FALSE;
		}
	}
}

/**
 *
 *
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	// xml
	if (AIMFileTypeXml == mFileType) {
		if (mInChat)
			if (mInMessage)
				[mXmlStr appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}
	else if (AIMFileTypeHtml == mFileType) {
		if (mInHtml && mInBody && mInDivMessage && (mInSpanHeader || mInSpanTimestamp || mInSpanBody))
			[mXmlStr appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}
}

/**
 *
 *
 */
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	// xml
	if (AIMFileTypeXml == mFileType) {
		if (mInChat)
			if (mInMessage)
				[mXmlStr appendString:[[NSString stringWithCString:(const char *)[CDATABlock bytes] encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}
	else if (AIMFileTypeHtml == mFileType) {
		if (mInHtml && mInBody && mInDivMessage && (mInSpanHeader || mInSpanTimestamp || mInSpanBody))
			[mXmlStr appendString:[[NSString stringWithCString:(const char *)[CDATABlock bytes] encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}
}

@end
