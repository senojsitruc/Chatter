//
//  ColloquyImporter.m
//  Chatter
//
//  Created by Jones Curtis on 2011.07.06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ColloquyImporter.h"
#import "ServiceStuff.h"
#import "NSString+Additions.h"
#import <errno.h>
#import <fcntl.h>
#import <string.h>

@interface ColloquyImporter (PrivateMethods)
- (BOOL)importData:(NSData *)data withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler;
@end

@implementation ColloquyImporter

/**
 * kMDItemContentType = 'info.colloquy.transcript'
 *
 * <log began="2011-07-06 16:59:06 +0000" source="irc://irc.foonetic.net/%23xkcd">
 *   <envelope>
 *     <sender hostmask="ChanServ@services.foonetic.net" identifier="chanserv">ChanServ</sender>
 *     <message id="HW7P5IYRAE3" received="2011-07-06 16:59:06 +0000" type="notice">[
 *       <a href="irc://irc.foonetic.net/#xkcd">#xkcd</a>] Channel guidelines: 
 *       <a href="http://www.xkcdb.com/channelrules">http://www.xkcdb.com/channelrules</a>
 *     </message>
 *   </envelope>
 *   <envelope>
 *     <sender hostmask="quack@hide-19AB3982.movistar.com.ni" identifier="sigma_">Sigma_</sender>
 *     <message id="W3JVAOYRAE3" received="2011-07-06 16:59:12 +0000"><span class="member">Bucket</span>: utf-8</message>
 *   </envelope>
 *   <envelope>
 *     <sender hostmask="bucket@irc.peeron.com" identifier="bucket">Bucket</sender>
 *     <message id="T4SVAOYRAE3" received="2011-07-06 16:59:12 +0000">utf-8 is ⓨⓞⓤⓡ ⓕⓐⓒⓔ ⓢⓤⓟⓟⓞⓡⓣⓢ ⓤⓣⓕ-⑧</message>
 *   </envelope>
 *   <envelope>
 *     <sender hostmask="quack@hide-19AB3982.movistar.com.ni" identifier="sigma_">Sigma_</sender>
 *     <message id="XGBUFVYRAE3" received="2011-07-06 16:59:19 +0000">switched to consolas, still missing all glyphs</message>
 *     <message id="JHR1JXYRAE3" received="2011-07-06 16:59:21 +0000">&lt;_&lt;</message>
 *     <message id="GL7AJEZRAE3" received="2011-07-06 16:59:38 +0000">also, consolas hurts my eyes</message>
 *   </envelope>
 *   <event id="M6KVB20SAE3" name="memberParted" occurred="2011-07-06 17:00:02 +0000">
 *     <message><span class="member">vikramverma</span>left the chat room.</message>
 *     <who hostmask="vikramverm@2DF9F78A.3667F83B.E52F97C6.IP">vikramverma</who>
 *     <reason>Ping timeout</reason>
 *   </event>
 *   <event id="OHYY3E3SAE3" name="memberJoined" occurred="2011-07-06 17:02:02 +0000">
 *     <message><span class="member">vikramverma</span>joined the chat room.</message>
 *     <who hostmask="vikramverm@2DF9F78A.3667F83B.E52F97C6.IP">vikramverma</who>
 *   </event>
 *   <event id="O2BYI3SAE3" name="memberParted" occurred="2011-07-06 17:02:06 +0000">
 *     <message><span class="member">vikramverma</span>left the chat room.</message>
 *     <who hostmask="vikramverm@2DF9F78A.3667F83B.E52F97C6.IP">vikramverma</who>
 *     <reason>Quit: vikramverma</reason>
 *   </event>
 * </log>
 */
+ (BOOL)canHandleFilePath:(NSString *)filePath
{
	BOOL retval=FALSE, isDir;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSDictionary *attributes;
	
	// the file must exist and it must not be a directory
	if (FALSE == [fileManager fileExistsAtPath:filePath isDirectory:&isDir] || isDir)
		goto done_fail;
	
	// if the file has the colloquy extension, it's good
	if (TRUE == [filePath hasSuffix:@".colloquyTranscript"])
		goto done_good;
	
	// if the file has the colloquy content type, it's good
	if (nil != (attributes = [ServiceStuff metadataAttributesForFilePath:filePath]))
		if ([[attributes objectForKey:(id)kMDItemContentType] isEqualToString:@"info.colloquy.transcript"])
			goto done_good;
	
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
		
		if (someData == nil) {
			close(fd);
			goto done_fail;
		}
		
		// xml
		if (NSNotFound != [someData rangeOfString:@"<log "].location &&
				NSNotFound != [someData rangeOfString:@"began="].location &&
				NSNotFound != [someData rangeOfString:@"source="].location) {
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
	}
	
	return self;
}

/**
 *
 *
 */





#pragma mark - Service Importer

+ (NSString *)name
{
	return @"Colloquy";
}

+ (NSArray *)supportedContentTypes
{
	return [NSArray arrayWithObjects:@"info.colloquy.transcript", nil];
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
	return [NSArray arrayWithObjects:@"colloquyTranscript", nil];
}

+ (NSArray *)supportedSearchPaths
{
	return [NSArray arrayWithObjects:@"~/Documents/Colloquy Transcripts", nil];
}

/**
 *
 *
 */
- (BOOL)importFileAtPath:(NSString *)filePath withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler
{
	BOOL isDir = FALSE;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir] || isDir) {
		return FALSE;
	}
	
	
	return [self importData:[NSData dataWithContentsOfFile:filePath] withMessageClass:messageClass andHandler:handler];
}

/**
 *
 *
 */
- (BOOL)importData:(NSData *)fileData withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler
{
	@autoreleasepool {
		NSMutableData *xmlData = [NSMutableData data];
		NSXMLParser *parser;
		
		[xmlData appendBytes:"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><chat>" length:45];
		[xmlData appendBytes:[fileData bytes] length:[fileData length]];
		
		parser = [[NSXMLParser alloc] initWithData:xmlData];
		
		mHandler = handler;
		mMessageClass = messageClass;
		
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
	mInLog = FALSE;
	mInEnvelope = FALSE;
	mInSender = FALSE;
	mInMessage = FALSE;
	mInSpan = FALSE;
	mInEvent = FALSE;
	mInWho = FALSE;
	mInReason = FALSE;
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
	if (mInLog) {
		if (mInEnvelope) {
			if (mInSender) {
			}
			else if (mInMessage) {
			}
			else if ([elementName isEqualToString:@"sender"]) {
				mSender = [attributeDict objectForKey:@"identifier"];
				mInSender = TRUE;
			}
			else if ([elementName isEqualToString:@"message"]) {
				mTimestamp = [attributeDict objectForKey:@"received"];
				mInMessage = TRUE;
			}
		}
		else if (mInEvent) {
			if (mInMessage) {
				if ([elementName isEqualToString:@"span"])
					mInSpan = TRUE;
			}
			else if (mInWho) {
			}
			else if (mInReason) {
			}
			else if ([elementName isEqualToString:@"message"])
				mInMessage = TRUE;
			else if ([elementName isEqualToString:@"who"])
				mInWho = TRUE;
			else if ([elementName isEqualToString:@"reason"])
				mInReason = TRUE;
		}
		else if ([elementName isEqualToString:@"envelope"])
			mInEnvelope = TRUE;
		else if ([elementName isEqualToString:@"event"]) {
			mEvent = [attributeDict objectForKey:@"name"];
			mTimestamp = [attributeDict objectForKey:@"occurred"];
			mInEvent = TRUE;
		}
	}
	else if ([elementName isEqualToString:@"log"])
		mInLog = TRUE;
}

/**
 *
 *
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if (mInLog) {
		if (mInEnvelope) {
			if (mInSender && [elementName isEqualToString:@"sender"]) {
				[mXmlStr setString:@""];
				mInSender = FALSE;
			}
			else if (mInMessage && [elementName isEqualToString:@"message"]) {
				if (mSender) {
					id<ServiceImporterMessage> message = [[(Class)mMessageClass alloc] init];
					BOOL stop = FALSE;
					
					[message setScreenname:[mSender lowercaseString]];
					[message setTimestampStr:mTimestamp];
					[message setMessage:[NSString stringWithString:mXmlStr]];
					
					mHandler(message, &stop);
					
					if (stop)
						[parser abortParsing];
				}
				
				[mXmlStr setString:@""];
				mMessage = nil;
				mInMessage = FALSE;
			}
			else if ([elementName isEqualToString:@"envelope"]) {
				mSender = nil;
				mTimestamp = nil;
				mMessage = nil;
				mInEnvelope = FALSE;
			}
		}
		else if (mInEvent) {
			if (mInMessage) {
				if (mInSpan && [elementName isEqualToString:@"span"]) {
					if ([mXmlStr length] != 0)
						[mXmlStr appendString:@" "];
					mInSpan = FALSE;
				}
				else if ([elementName isEqualToString:@"message"]) {
					mMessage = [NSString stringWithString:mXmlStr];
					[mXmlStr setString:@""];
					mInMessage = FALSE;
				}
			}
			else if (mInWho && [elementName isEqualToString:@"who"]) {
				mSender = [NSString stringWithString:mXmlStr];
				[mXmlStr setString:@""];
				mInWho = FALSE;
			}
			else if (mInReason && [elementName isEqualToString:@"reason"])
				mInReason = FALSE;
			else if ([elementName isEqualToString:@"event"]) {
				if (mSender) {
					id<ServiceImporterMessage> message = [[(Class)mMessageClass alloc] init];
					BOOL stop = FALSE;
					
					[message setScreenname:[mSender lowercaseString]];
					[message setTimestampStr:mTimestamp];
					[message setMessage:mMessage];
					
					mHandler(message, &stop);
					
					if (stop)
						[parser abortParsing];
				}
				
				[mXmlStr setString:@""];
				mMessage = nil;
				mInEvent = FALSE;
			}
		}
		else if ([elementName isEqualToString:@"log"])
			mInLog = FALSE;
	}
}

/**
 *
 *
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (mInLog) {
		if (mInEnvelope && (mInSender || mInMessage))
			[mXmlStr appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
		else if (mInEvent && (mInMessage || mInWho || mInReason))
			[mXmlStr appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}
}

/**
 *
 *
 */
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	if (mInLog) {
		if (mInEnvelope && (mInSender || mInMessage))
			[mXmlStr appendString:[[NSString stringWithCString:(const char *)[CDATABlock bytes] encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
		else if (mInEvent && (mInMessage || mInWho || mInReason))
			[mXmlStr appendString:[[NSString stringWithCString:(const char *)[CDATABlock bytes] encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}
}

@end
