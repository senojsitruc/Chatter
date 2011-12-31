//
//  AdiumImporter.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AdiumImporter.h"
#import "ServiceStuff.h"

@interface AdiumImporter (PrivateMethods)
+ (NSString *)adiumDateToStandard:(NSString *)adiumDate;
- (BOOL)importData:(NSData *)data withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler;
@end

@implementation AdiumImporter

/**
 * kMDItemKind = Adium Chat Log
 * kMDItemContentType = com.adiumx.xmllog
 */
+ (BOOL)canHandleFilePath:(NSString *)filePath
{
	BOOL retval=FALSE, isDir;
	NSDictionary *attributes;
	NSString *contentType;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if (FALSE == [fileManager fileExistsAtPath:filePath isDirectory:&isDir] || !isDir)
		goto done_fail;
	
	if ([filePath hasSuffix:@".chatlog"])
		goto done_good;
	
	if (nil == (attributes = [ServiceStuff metadataAttributesForFilePath:filePath]))
		goto done_fail;
	
	contentType = [attributes objectForKey:(id)kMDItemContentType];
	
	if (contentType == nil || FALSE == [contentType isEqualToString:@"com.adiumx.xmllog"])
		goto done_fail;
	
done_good:
	retval = TRUE;
	
done_fail:
	[fileManager release];
	return retval;
}

/**
 * 2011-06-23T23:16:16-04:00 -> 2011-06-23 23:16:16 -0400
 *
 */
+ (NSString *)adiumDateToStandard:(NSString *)adiumDate
{
	char datestr[26] = { 0 };
	
	if ([adiumDate length] != 25)
		return nil;
	
	memcpy(datestr, [adiumDate cStringUsingEncoding:NSUTF8StringEncoding], 25);
	
	datestr[10] = ' ';
	datestr[24] = datestr[24];
	datestr[23] = datestr[23];
	datestr[22] = datestr[21];
	datestr[21] = datestr[20];
	datestr[20] = datestr[19];
	datestr[19] = ' ';
	
	return [NSString stringWithCString:datestr encoding:NSUTF8StringEncoding];
}

/**
 *
 *
 */
- (id)init
{
	self = [super init];
	
	if (self) {
		mMessageStr = [[NSMutableString alloc] init];
	}
	
	return self;
}

/**
 *
 *
 */
- (void)dealloc
{
	[mMessageStr release];
	[super dealloc];
}





#pragma mark - ServiceImporter

+ (NSString *)name
{
	return @"Adium";
}

+ (NSArray *)supportedContentTypes
{
	return [NSArray arrayWithObjects:@"com.adiumx.xmllog", nil];
}

+ (NSArray *)supportedTypeCodes
{
	return nil;
}

+ (NSArray *)supportedKinds
{
	return [NSArray arrayWithObjects:@"Adium Chat Log", nil];
}

+ (NSArray *)supportedFileExtensions
{
	return [NSArray arrayWithObjects:@"chatlog", nil];
}

+ (NSArray *)supportedSearchPaths
{
	return [NSArray arrayWithObjects:@"~/Library/Application Support/Adium 2.0/Users/Default/Logs", nil];
}

/**
 * The "file" that we can identify as an Adium chat log is actually a directory. There is an XML
 * file in this directory. We want to parse that file. Not this directory.
 */
- (BOOL)importFileAtPath:(NSString *)filePath withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler
{
	BOOL retval, isDir;
	NSString *xmlFilePath = nil;
	NSUInteger good=0, bad=0;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if (TRUE == [fileManager fileExistsAtPath:filePath isDirectory:&isDir] && isDir) {
		NSArray *files = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
		
		if ([files count] != 0) {
			for (NSString *logFileName in files) {
				xmlFilePath = [filePath stringByAppendingPathComponent:logFileName];
				retval = [self importData:[NSData dataWithContentsOfFile:xmlFilePath] withMessageClass:messageClass andHandler:handler];
				if (retval) good++; else bad++;
			}
		}
	}
	
	[fileManager release];
	
	return good;
}

/**
 *
 *
 */
- (BOOL)importData:(NSData *)data withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	
	mHandler = handler;
	mMessageClass = messageClass;
	
	[parser setDelegate:self];
	[parser parse];
	[parser release];
	
	mHandler = nil;
	
	[mSender release];
	mSender = nil;
	
	[pool release];
	
	return TRUE;
}





#pragma mark - NSXMLParserDelegate

/**
 *
 *
 */
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	mInChat = FALSE;
	mInEvent = FALSE;
	mInMessage = FALSE;
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
	if (mInChat) {
		if (mInEvent) {
			// nothing should ever happen here
		}
		else if (mInMessage) {
			
		}
		else if ([elementName isEqualToString:@"event"]) {
			mInEvent = TRUE;
			mSender = [[attributeDict objectForKey:@"sender"] retain];
		}
		else if ([elementName isEqualToString:@"message"]) {
			mInMessage = TRUE;
			mMessageSender = [[attributeDict objectForKey:@"sender"] retain];
			mMessageTime = [[attributeDict objectForKey:@"time"] retain];
		}
	}
	else if ([elementName isEqualToString:@"chat"]) {
		mInChat = TRUE;
		mServiceName = [[attributeDict objectForKey:@"account"] retain];
	}
}

/**
 *
 *
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if (mInChat) {
		if (mInEvent && [elementName isEqualToString:@"event"])
			mInEvent = FALSE;
		else if (mInMessage && [elementName isEqualToString:@"message"]) {
			id<ServiceImporterMessage> message = [[(Class)mMessageClass alloc] init];
			BOOL stop = FALSE;
			
			[message setScreenname:mMessageSender];
			[message setTimestampStr:[AdiumImporter adiumDateToStandard:mMessageTime]];
			[message setMessage:[NSString stringWithString:mMessageStr]];
			
			mHandler(message, &stop);
			
			if (stop)
				[parser abortParsing];
			
			[message release];
			
			[mMessageSender release];
			mMessageSender = nil;
			
			[mMessageTime release];
			mMessageTime = nil;
			
			[mMessageStr setString:@""];
			
			mInMessage = FALSE;
		}
		else if ([elementName isEqualToString:@"chat"]) {
			mInChat = FALSE;
			[mServiceName release];
			mServiceName = nil;
		}
	}
}

/**
 *
 *
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (mInChat)
		if (mInMessage)
			[mMessageStr appendString:string];
}

/**
 *
 *
 */
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	if (mInChat)
		if (mInMessage)
			[mMessageStr appendString:[NSString stringWithCString:(const char *)[CDATABlock bytes] encoding:NSUTF8StringEncoding]];
}

@end
