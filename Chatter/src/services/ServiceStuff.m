//
//  ServiceStuff.m
//  Chatter
//
//  Created by Jones Curtis on 2011.07.09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServiceStuff.h"

@implementation ServiceStuff

/**
 *
 *
 */
+ (NSDictionary *)metadataAttributesForFilePath:(NSString *)filePath
{
	MDItemRef mditem = MDItemCreate(kCFAllocatorDefault, (CFStringRef)filePath);
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
	
	for (NSObject *key in (NSDictionary *)attributeValues)
		[attributes setObject:[(NSDictionary *)attributeValues objectForKey:key] forKey:key];
	
done:
	if (mditem != NULL)
		CFRelease(mditem);
	
	if (attributeNames != NULL)
		CFRelease(attributeNames);
	
	if (attributeValues != NULL)
		CFRelease(attributeValues);
	
	return attributes;
}

@end
