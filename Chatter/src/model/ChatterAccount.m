//
//  ChatterAccount.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterAccount.h"
#import "ChatterPerson.h"
#import "ChatterObjectCache.h"
#import "Easy.h"

@implementation ChatterAccount

@synthesize personId = mPersonId;
@synthesize screenname = mScreenName;
@synthesize iconName = mIconName;
@dynamic image;
@dynamic person;





#pragma mark - Structors

/**
 *
 *
 */
+ (id)account
{
	return [[[[self class] alloc] init] autorelease];
}

/**
 *
 *
 */
- (id)init
{
	self = [super init];
	
	if (self) {
		mIconName = [[NSString alloc] initWithFormat:@"user-%03d.png", 1+(random()%7)];
	}
	
	return self;
}

/**
 *
 *
 */
- (void)dealloc
{
	[mScreenName release];
	[mIconName release];
	[mImage release];
	
	[super dealloc];
}





#pragma mark - Accessors

/**
 *
 *
 */;
- (NSImage *)image
{
	NSData *imageData;
	NSString *filePath;
	NSImage *image;
	
	if (mImage != nil)
		return mImage;
	else if (nil != self.person && nil != (image = mPerson.image))
		return image;
	
	filePath = [[Easy imagePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"account/%lu.png", mDatabaseId]];
	imageData = [[NSData alloc] initWithContentsOfFile:filePath];
	
	if (imageData != nil) {
		mImage = [[NSImage alloc] initWithData:imageData];
		mImage.size = NSMakeSize(32., 32.);
		[imageData release];
	}
	else {
		image = [NSImage imageNamed:mIconName];
		image.size = NSMakeSize(32., 32.);
		mImage = [image retain];
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
	
	NSString *accountImagesPath = [[Easy imagePath] stringByAppendingPathComponent:@"account"];
	NSString *filePath = [accountImagesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.png", mDatabaseId]];
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	[mImage release];
	mImage = [image retain];
	
	if (FALSE == [fileManager fileExistsAtPath:accountImagesPath]) {
		if (FALSE == [fileManager createDirectoryAtPath:accountImagesPath withIntermediateDirectories:TRUE attributes:nil error:nil]) {
			NSLog(@"%s.. failed to create directory path, '%@'", __PRETTY_FUNCTION__, accountImagesPath);
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
	
	[fileManager release];
}

/**
 *
 *
 */
- (ChatterPerson *)person
{
	if (mPerson != nil)
		return mPerson;
	else if (mPersonId != 0)
		return (mPerson = [[ChatterObjectCache sharedInstance] personForId:mPersonId]);
	else
		return nil;
}

/**
 *
 *
 */
- (void)setPerson:(ChatterPerson *)person
{
	if (person == mPerson)
		return;
	
	mPersonId = person.databaseId;
	mPerson = person;
}

@end
