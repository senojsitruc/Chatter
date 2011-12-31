//
//  NSApplication+Additions.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSApplication+Additions.h"

@implementation NSApplication (SystemVersion)

/**
 *
 *
 */
- (void)systemVersionMajor:(unsigned int *)major minor:(unsigned int *)minor bugFix:(unsigned int *)bugFix
{
	OSErr err;
	SInt32 systemVersion, versionMajor, versionMinor, versionBugFix;
	
	if ((err = Gestalt(gestaltSystemVersion, &systemVersion)) != noErr)
		goto fail;
	
	if (systemVersion < 0x1040)
	{
		if (major) *major = ((systemVersion & 0xF000) >> 12) * 10 + ((systemVersion & 0x0F00) >> 8);
		if (minor) *minor = (systemVersion & 0x00F0) >> 4;
		if (bugFix) *bugFix = (systemVersion & 0x000F);
	}
	else
	{
		if ((err = Gestalt(gestaltSystemVersionMajor, &versionMajor)) != noErr) goto fail;
		if ((err = Gestalt(gestaltSystemVersionMinor, &versionMinor)) != noErr) goto fail;
		if ((err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix)) != noErr) goto fail;
		if (major) *major = versionMajor;
		if (minor) *minor = versionMinor;
		if (bugFix) *bugFix = versionBugFix;
	}
	
	return;
	
fail:
	if (major) *major = 10;
	if (minor) *minor = 0;
	if (bugFix) *bugFix = 0;
}

/**
 *
 *
 */
- (NSString *)systemVersionString
{
	unsigned int major, minor, bugFix;
	
	[self systemVersionMajor:&major minor:&minor bugFix:&bugFix];
	
	return [NSString stringWithFormat:@"%u.%u.%u", major, minor, bugFix];
}

@end
