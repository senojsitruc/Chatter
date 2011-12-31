//
//  iChatImporter.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iChatImporter.h"
#import "ServiceStuff.h"
#import "InstantMessage.h"
#import "Person.h"
#import "Presentity.h"
#import "NSString+Additions.h"

#define kFlagsMessage		(1 << 0)    // is a message (or status change)
#define kFlagsDirection	(1 << 2)    // 1=outgoing, 0=incoming
#define kFlagsAway1			(1 << 26)   // 
#define kFlagsAway2			(1 << 27)   // 

@interface iChatImporter (PrivateMethods)
- (BOOL)importData:(NSData *)data withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler;
@end

@implementation iChatImporter

/**
 * kMDItemContentType = com.apple.ichat.transcript
 * kMDItemKind = Chat transcript
 * kMDItemAuthorAddresses = curtis.jones@gmail.com
 */
+ (BOOL)canHandleFilePath:(NSString *)filePath
{
	BOOL retval=FALSE, isDir;
	NSDictionary *attributes;
	NSString *contentType;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if (FALSE == [fileManager fileExistsAtPath:filePath isDirectory:&isDir] || isDir)
		goto done_fail;
	
	if ([filePath hasSuffix:@".ichat"])
		goto done_good;
	
	if (nil == (attributes = [ServiceStuff metadataAttributesForFilePath:filePath]))
		goto done_fail;
	
	contentType = [attributes objectForKey:(id)kMDItemContentType];
	
	if (FALSE == [contentType isEqualToString:@"com.apple.ichat.transcript"])
		goto done_fail;
	
done_good:
	retval = TRUE;
	
done_fail:
	[fileManager release];
	return retval;
}





#pragma mark - ServiceImporter

+ (NSString *)name
{
	return @"iChat";
}

+ (NSArray *)supportedContentTypes
{
	return [NSArray arrayWithObjects:@"com.apple.ichat.transcript", nil];
}

+ (NSArray *)supportedTypeCodes
{
	return nil;
}

+ (NSArray *)supportedKinds
{
	return [NSArray arrayWithObjects:@"Chat transcript", nil];
}

+ (NSArray *)supportedFileExtensions
{
	return [NSArray arrayWithObjects:@"ichat", nil];
}

+ (NSArray *)supportedSearchPaths
{
	return [NSArray arrayWithObjects:@"~/Documents/iChats", nil];
}

/**
 *
 *
 */
- (BOOL)importFileAtPath:(NSString *)filePath withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler
{
	NSDictionary *metadata = [ServiceStuff metadataAttributesForFilePath:filePath];
	NSArray *serviceNames = [metadata objectForKey:@"kMDItemAuthorAddresses"];
	NSString *serviceName = nil;
	BOOL isDir = FALSE;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir] || isDir) {
		[fileManager release];
		return FALSE;
	}
	
	__block NSMutableArray *messages = [NSMutableArray array];
	__block NSTimeInterval lastTimestamp = 0.;
	
	serviceName = [serviceNames objectAtIndex:0];
	
	return [self importData:[NSData dataWithContentsOfFile:filePath] withMessageClass:messageClass andHandler:(^ (id<ServiceImporterMessage> message, BOOL *stop) {
		if ([message screenname] == nil)
			[message setScreenname:serviceName];
		
		if ([message timestamp] == nil) {
			[messages addObject:message];
			return;
		}
		else if ([messages count] != 0) {
			NSTimeInterval timestamp = [[message timestamp] timeIntervalSinceReferenceDate] - [messages count];
			
			for (id<ServiceImporterMessage> message2 in messages) {
				[message2 setTimestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:timestamp++]];
				handler(message2, stop);
			}
			
			[messages removeAllObjects];
		}
		
		lastTimestamp = [[message timestamp] timeIntervalSinceReferenceDate];
		
		handler(message, stop);
	})];
	
	if ([messages count] != 0) {
		BOOL stop = FALSE;
		
		if (lastTimestamp == 0.)
			lastTimestamp = [NSDate timeIntervalSinceReferenceDate] - [messages count];
		
		for (id<ServiceImporterMessage> message2 in messages) {
			[message2 setTimestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:lastTimestamp++]];
			handler(message2, &stop);
			
			if (stop)
				break;
		}
		
		[messages removeAllObjects];
	}
	
	[fileManager release];
	
	return TRUE;
}

/**
 *
 *
 */
- (BOOL)importData:(NSData *)data withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler
{
	if (data == nil) {
		NSLog(@"%s.. nil data!", __PRETTY_FUNCTION__);
		return FALSE;
	}
	
	NSArray *chat = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSArray *messages = [chat objectAtIndex:2];
	NSString *remotesn = ((Presentity *)[[chat objectAtIndex:3] objectAtIndex:0]).senderID;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	for (NSObject *object in messages) {
		if ([object isKindOfClass:[InstantMessage class]]) {
			if ([[((InstantMessage *)object).text string] length] == 0)
				continue;
			
			InstantMessage *im = (InstantMessage *)object;
			NSUInteger flags = im.flags;
			BOOL incoming = TRUE;
			id<ServiceImporterMessage> message = [[(Class)messageClass alloc] init];
			BOOL stop = FALSE;
			
			if ((flags & kFlagsAway1) || (flags & kFlagsAway2))
				continue;
			else if (flags & kFlagsDirection)
				incoming = FALSE;
			
			if (incoming)
				[message setScreenname:[remotesn lowercaseString]];
			
			[message setTimestamp:im.date];
			[message setMessage:[[im.text string] stringByTrimmingTrailingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
			
			handler(message, &stop);
			
			if (stop)
				break;
			
			[message release];
		}
	}
	
	[pool release];
	
	return TRUE;
}

@end
