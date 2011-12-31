//
//  TrillianImporter.m
//  Chatter
//
//  Created by Jones Curtis on 2011.07.03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrillianImporter.h"
#import "Coder.h"
#import <errno.h>
#import <fcntl.h>
#import <string.h>

@interface TrillianImporter (PrivateMethods)
- (BOOL)importData:(NSData *)data withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler;
@end

@implementation TrillianImporter

/**
 *
 *
 */
+ (BOOL)canHandleFilePath:(NSString *)filePath
{
	BOOL retval=FALSE, isDir;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	// the file must exist and it must not be a directory
	if (FALSE == [fileManager fileExistsAtPath:filePath isDirectory:&isDir] || isDir)
		goto done_fail;
	
	// the file must have an "xml" extension
	if (FALSE == [filePath hasSuffix:@".xml"])
		goto done_fail;
	
	// the file must start with 0xEF BB BF
	{
		unsigned char buf[3] = { 0 };
		int fd = open([filePath cStringUsingEncoding:NSUTF8StringEncoding], O_RDONLY);
		
		if (fd == -1)
			goto done_fail;
		
		ssize_t bytes = read(fd, buf, 3);
		
		if (bytes != 3) {
			close(fd);
			goto done_fail;
		}
		else if (0xEF != buf[0] || 0xBB != buf[1] || 0xBF != buf[2]) {
			close(fd);
			goto done_fail;
		}
		
		close(fd);
	}
	
done_good:
	retval = TRUE;
	
done_fail:
	[fileManager release];
	return retval;
}





#pragma mark - Service Importer

+ (NSString *)name
{
	return @"Trillian";
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
	return [NSArray arrayWithObjects:@"~/Library/Application Support/Trillian/", nil];
}

/**
 * The "file" that we can identify as an Adium chat log is actually a directory. There is an XML
 * file in this directory. We want to parse that file. Not this directory.
 */
- (BOOL)importFileAtPath:(NSString *)filePath withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler
{
	BOOL isDir = FALSE;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir] || isDir) {
		[fileManager release];
		return FALSE;
	}
	
	[fileManager release];
	
	return [self importData:[NSData dataWithContentsOfFile:filePath] withMessageClass:messageClass andHandler:handler];
}

/**
 *
 *
 */
- (BOOL)importData:(NSData *)fileData withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableData *xmlData = [NSMutableData data];
	NSXMLParser *parser;
	const unsigned char *fileBytes = (const unsigned char *)[fileData bytes];
	
	mMessageClass = messageClass;
	mHandler = handler;
	
	if ([fileData length] < 3)
		return FALSE;
	
	if (fileBytes[0] != 0xEF || fileBytes[1] != 0xBB || fileBytes[2] != 0xBF)
		return FALSE;
	
	[xmlData appendBytes:"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><chat>" length:45];
	[xmlData appendBytes:fileBytes+3 length:[fileData length]-3];
	[xmlData appendBytes:"</chat>\n" length:8];
	
	parser = [[NSXMLParser alloc] initWithData:xmlData];
	
	mHandler = handler;
	
	[parser setDelegate:self];
	[parser parse];
	[parser release];
	
	mHandler = nil;
	
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
}

/**
 *
 *
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[mServiceName release];
	mServiceName = nil;
}

/**
 *
 *
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if (mInChat) {
		if ([elementName isEqualToString:@"session"]) {
			[mServiceName release];
			mServiceName = [[attributeDict objectForKey:@"from"] retain];
		}
		else if ([elementName isEqualToString:@"message"]) {
			id<ServiceImporterMessage> message = [[(Class)mMessageClass alloc] init];
			BOOL stop = FALSE;
			
			[message setScreenname:[attributeDict objectForKey:@"from"]];
			[message setTimestamp:[NSDate dateWithTimeIntervalSince1970:([[attributeDict objectForKey:@"time"] doubleValue] + ([[attributeDict objectForKey:@"ms"] doubleValue] / 1000.))]];
			[message setMessage:[Coder urlDecode:[attributeDict objectForKey:@"text"]]];
			
			mHandler(message, &stop);
			
			if (stop)
				[parser abortParsing];
			
			[message release];
		}
	}
	else if ([elementName isEqualToString:@"chat"])
		mInChat = TRUE;
}

/**
 *
 *
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if (mInChat)
		if ([elementName isEqualToString:@"chat"])
			mInChat = FALSE;
}

/**
 *
 *
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	
}

/**
 *
 *
 */
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	
}

@end
