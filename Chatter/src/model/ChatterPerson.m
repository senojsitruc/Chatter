//
//  ChatterPerson.m
//  Chatter
//
//  Created by Jones Curtis on 2011.06.27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterPerson.h"
#import "Easy.h"

@implementation ChatterPerson

@dynamic name;
@dynamic image;
@dynamic firstName;
@dynamic lastName;
@synthesize addressBookUid = mAddressBookUid;





#pragma mark - Structors

/**
 *
 *
 */
+ (id)person
{
	return [[[self class] alloc] init];
}

/**
 *
 *
 */
- (void)dealloc
{
	self.firstName = nil;
	self.lastName = nil;
}





#pragma mark - Accessors

/**
 *
 *
 */
- (NSString *)firstName
{
	return mFirstName;
}

/**
 *
 *
 */
- (void)setFirstName:(NSString *)firstName
{
	mFirstName = firstName;
	mFullName = nil;
}

/**
 *
 *
 */
- (NSString *)lastName
{
	return mLastName;
}

/**
 *
 *
 */
- (void)setLastName:(NSString *)lastName
{
	mLastName = lastName;
	mFullName = nil;
}

/**
 *
 *
 */
- (NSString *)name
{
	if ([mFirstName length] != 0 && [mLastName length] != 0) {
		if (mFullName)
			return mFullName;
		else {
			mFullName = [NSMutableString string];
			[mFullName appendString:mFirstName];
			[mFullName appendString:@" "];
			[mFullName appendString:mLastName];
			return mFullName;
		}
	}
	else if ([mFirstName length] != 0)
		return mFirstName;
	else
		return mLastName;
	
	/*
	if ([mFirstName length] != 0 && [mLastName length] != 0)
		return [NSString stringWithFormat:@"%@ %@", mFirstName, mLastName];
	else if ([mFirstName length] != 0)
		return mFirstName;
	else
		return mLastName;
	*/
}

/**
 *
 *
 */;
- (NSImage *)image
{
	NSData *imageData;
	NSString *filePath;
	
	if (mImage != nil)
		return mImage;
	
	filePath = [[Easy imagePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"person/%lu.png", mDatabaseId]];
	imageData = [[NSData alloc] initWithContentsOfFile:filePath];
	
	if (imageData != nil) {
		mImage = [[NSImage alloc] initWithData:imageData];
		mImage.size = NSMakeSize(32., 32.);
	}
	
	return mImage;
}

/**
 *
 *
 */
- (void)setImage:(NSImage *)image
{
	if (mDatabaseId == 0) {
		NSLog(@"%s.. can't save an image without first being added to the database", __PRETTY_FUNCTION__);
		return;
	}
	
	NSString *personImagesPath = [[Easy imagePath] stringByAppendingPathComponent:@"person"];
	NSString *filePath = [personImagesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.png", mDatabaseId]];
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	mImage = image;
	
	if (FALSE == [fileManager fileExistsAtPath:personImagesPath]) {
		if (FALSE == [fileManager createDirectoryAtPath:personImagesPath withIntermediateDirectories:TRUE attributes:nil error:nil]) {
			NSLog(@"%s.. failed to create directory path, '%@'", __PRETTY_FUNCTION__, personImagesPath);
			return;
		}
	}
	
	// there's no image so remove the image from disk (if there is one)
	if (image == nil)
		[fileManager removeItemAtPath:filePath error:nil];
	
	// there is an image so write it to disk
	else {
		NSBitmapImageRep *bitmap = [[mImage representations] objectAtIndex:0];
		NSData *data = [bitmap representationUsingType:NSPNGFileType properties:nil];
		[data writeToFile:filePath atomically: NO];
	}
	
}

@end
