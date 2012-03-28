//
//  Easy.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Easy.h"
#import "DBConnection.h"
#import <errno.h>
#import <fts.h>
#import <string.h>
#import <sys/stat.h>
#import <objc/runtime.h>

static Easy *gEasy;
static DBConnection *gDbConn;

@implementation Easy





#pragma mark - Structors

/**
 *
 *
 */
+ (void)initialize
{
	gEasy = [[Easy alloc] init];
}

/**
 *
 *
 */
+ (Easy *)sharedInstance
{
	return gEasy;
}





#pragma mark - Database

/**
 *
 *
 */
+ (DBConnection *)dbconn
{
	return gDbConn;
}

/**
 *
 *
 */
+ (void)setDbConn:(DBConnection *)dbconn
{
	gDbConn = dbconn;
}





#pragma mark - Files and Paths

/**
 *
 *
 */
+ (NSString *)sqlPath
{
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources/sql"];
}

/**
 *
 *
 */
+ (NSString *)imagePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	
	if (0 != [paths count])
		return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Chatter/images"];
	else
		return nil;
}

/**
 *
 *
 */
+ (NSString *)pathToApplicationSupportDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	
	if (0 != [paths count])
		return [paths objectAtIndex:0];
	else
		return nil;
}

/**
 *
 *
 */
+ (NSString *)pathToDocumentsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	if (0 != [paths count])
		return [paths objectAtIndex:0];
	else
		return nil;
}

/**
 *
 *
 */
+ (void)iterateDirectory:(NSString *)directoryPath withHandle:(void (^)(NSString *filePath))handler
{
	@autoreleasepool {
		const char * paths[2] = { NULL, NULL };
		FTS *tree;
		FTSENT *node;
		
		paths[0] = [directoryPath cStringUsingEncoding:NSUTF8StringEncoding];
		
		if (NULL == (tree = fts_open((char * const *)paths, FTS_NOSTAT /*FTS_NOCHDIR*/, 0))) {
			NSLog(@"%s.. failed to fts_open(%@)", __PRETTY_FUNCTION__, directoryPath);
			return;
		}
		
		while (NULL != (node = fts_read(tree))) {
			if (node->fts_level > 0 && node->fts_name[0] == '.')
				fts_set(tree, node, FTS_SKIP);
			else if ((node->fts_info & FTS_F) || (node->fts_info & FTS_D))
				handler([NSString stringWithCString:node->fts_path encoding:NSUTF8StringEncoding]);
		}
		
		fts_close(tree);
	}
}

/**
 *
 *
 */
+ (NSUInteger)mtimeForFilePath:(NSString *)filePath
{
	struct stat fileStat;
	
	if (0 == stat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &fileStat))
		return fileStat.st_mtimespec.tv_sec;
	else {
		NSLog(@"%s.. failed to stat(%@), %s", __PRETTY_FUNCTION__, filePath, strerror(errno));
		return 0;
	}
}

/**
 *
 *
 */
+ (NSDictionary *)metadataAttributesForFilePath:(NSString *)filePath
{
	MDItemRef mditem = MDItemCreate(kCFAllocatorDefault, (__bridge CFStringRef)filePath);
	CFArrayRef attributeNames = NULL;
	CFDictionaryRef attributeValues = NULL;
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	if (NULL == mditem) {
		//NSLog(@"%s.. failed to MDItemCreate(%@)", __PRETTY_FUNCTION__, filePath);
		goto done;
	}
	
	if (NULL == (attributeNames = MDItemCopyAttributeNames(mditem))) {
		NSLog(@"%s.. failed to MDItemCopyAttributeNames(%@)", __PRETTY_FUNCTION__, filePath);
		goto done;
	}
	
	if (NULL == (attributeValues = MDItemCopyAttributes(mditem, attributeNames))) {
		NSLog(@"%s.. failed to MDItemCopyAttributes(%@)", __PRETTY_FUNCTION__, filePath);
		goto done;
	}
	
	for (NSObject *key in (__bridge NSDictionary *)attributeValues)
		[attributes setObject:[(__bridge NSDictionary *)attributeValues objectForKey:key] forKey:key];
	
done:
	if (mditem != NULL)
		CFRelease(mditem);
	
	if (attributeNames != NULL)
		CFRelease(attributeNames);
	
	if (attributeValues != NULL)
		CFRelease(attributeValues);
	
	return attributes;
}

/**
 *
 *
 */
+ (void)revealFileInFinder:(NSString *)filePath
{
	[[NSWorkspace sharedWorkspace] selectFile:filePath inFileViewerRootedAtPath:nil];
}





#pragma mark - Notifications

/**
 *
 *
 */
+ (void)postNotification:(NSString *)name object:(id)object
{
	[[Easy sharedInstance] performSelectorOnMainThread:@selector(postNotificationOnMainThread:)
																					withObject:[NSNotification notificationWithName:name object:object]
																			 waitUntilDone:FALSE];
}

/**
 *
 *
 */
+ (void)postNotification:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo
{
	[[Easy sharedInstance] performSelectorOnMainThread:@selector(postNotificationOnMainThread:)
																					withObject:[NSNotification notificationWithName:name object:object userInfo:userInfo]
																			 waitUntilDone:FALSE];
}

/**
 *
 *
 */
- (void)postNotificationOnMainThread:(NSNotification *)notification
{
	// Coalescing has been disabled because it can cause multiple "item inserted" messages on the same parent object to be coalesced.
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification
																						 postingStyle:NSPostWhenIdle
																						 coalesceMask:NSNotificationNoCoalescing //NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
																								 forModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, nil]];
}





#pragma mark - Graphics

/**
 *
 *
 */
+ (CGFloat)heightForStringDrawing:(NSString *)aString withFont:(NSFont *)aFont andWidth:(CGFloat)myWidth
{
	if (FALSE == [aString hasSuffix:@"\n"])
		aString = [aString stringByAppendingString:@"\n"];
	
	CGFloat height = 0.;
	NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:aString];
	NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(myWidth,FLT_MAX)];
	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
	
//[layoutManager setTypesetterBehavior:NSTypesetterLatestBehavior];
	[layoutManager addTextContainer:textContainer];
	
	[textStorage addLayoutManager:layoutManager];
	[textStorage addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0,[textStorage length])];
	
	[textContainer setLineFragmentPadding:0.0];
	
	[layoutManager glyphRangeForTextContainer:textContainer];	
	
	height = [layoutManager usedRectForTextContainer:textContainer].size.height;
	
	return height;
}





#pragma mark - Funky

/**
 *
 *
 */
+ (Class)classForName:(NSString *)className
{
	return objc_getClass([className UTF8String]);
}

/**
 * Searches for loadable bundles in the system standard locations + the provided sub-directory.
 * Returns the absolute paths for all such bundles.
 *
 */
+ (NSArray *)allBundlesInDirectory:(NSString *)subdir withExtension:(NSString *)bundleExtension
{
	NSMutableArray *searchPaths = [[NSMutableArray alloc] init];
	NSMutableArray *bundlePaths = [NSMutableArray array];
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	for (NSString *searchPath in NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask-NSSystemDomainMask, TRUE)) {
		[searchPaths addObject:[searchPath stringByAppendingPathComponent:subdir]];
	}
	
	[searchPaths addObject:[[NSBundle mainBundle] builtInPlugInsPath]];
	
	for (NSString *searchPath in searchPaths) {
		for (NSString *filePath in [fileManager contentsOfDirectoryAtPath:searchPath error:nil]) {
			if ([[filePath pathExtension] isEqualToString:bundleExtension])
				[bundlePaths addObject:[searchPath stringByAppendingPathComponent:filePath]];
		}
	}
	
	return bundlePaths;
}

@end
