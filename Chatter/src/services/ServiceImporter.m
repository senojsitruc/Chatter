//
//  ServiceImporter.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServiceImporter.h"
#import "Easy.h"

static NSMutableDictionary *gImporters;

@implementation ServiceImporter

/**
 *
 *
 */
+ (void)initialize
{
	gImporters = [[NSMutableDictionary alloc] init];
}

/**
 *
 *
 */
+ (void)loadImporters
{
	Class<ServiceImporter> pluginClass;
	NSBundle *pluginBundle;
	NSArray *pluginPaths = [Easy allBundlesInDirectory:@"Chatter/Plug-Ins" withExtension:@"chatterImporter"];
	
	for (NSString *pluginPath in pluginPaths) {
		if (nil != (pluginBundle = [NSBundle bundleWithPath:pluginPath])) {
			if (nil != (pluginClass = [pluginBundle principalClass])) {
				if ([(Class)pluginClass conformsToProtocol:@protocol(ServiceImporter)]) {
					[gImporters setObject:[[[(Class)pluginClass alloc] init] autorelease] forKey:[pluginClass name]];
					NSLog(@"Registered importer %@", NSStringFromClass(pluginClass));
				}
			}
		}
	}
}

/**
 *
 *
 */
+ (NSArray *)importers
{
	return [gImporters allValues];
}

/**
 *
 *
 */
+ (id<ServiceImporter>)importerForName:(NSString *)importerName
{
	return [gImporters objectForKey:importerName];
}

/**
 *
 *
 */
+ (id<ServiceImporter>)importerForFilePath:(NSString *)filePath
{
	/*
	NSDictionary *attributes = [Easy metadataAttributesForFilePath:filePath];
	
	for (id key in [attributes allKeys])
		NSLog(@"  '%@' = '%@'", key, [attributes objectForKey:key]);
	*/
	
	for (id<ServiceImporter> importer in [gImporters allValues]) {
		if ([[importer class] canHandleFilePath:filePath])
			return importer;
	}
	
	return nil;
}

@end
