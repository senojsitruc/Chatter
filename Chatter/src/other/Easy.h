//
//  Easy.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBConnection;

@interface Easy : NSObject
{
	
}

/**
 * Stuff
 */
+ (void)initialize;
+ (Easy *)sharedInstance;

/**
 * Database stuff
 */
+ (DBConnection *)dbconn;
+ (void)setDbConn:(DBConnection *)dbconn;

/**
 * Files and paths
 */
+ (NSString *)sqlPath;
+ (NSString *)imagePath;
+ (NSString *)pathToApplicationSupportDirectory;
+ (NSString *)pathToDocumentsDirectory;
+ (void)iterateDirectory:(NSString *)directoryPath withHandle:(void (^)(NSString *filePath))handler;
+ (NSUInteger)mtimeForFilePath:(NSString *)filePath;
+ (NSDictionary *)metadataAttributesForFilePath:(NSString *)filePath;
+ (void)revealFileInFinder:(NSString *)filePath;

/**
 * Notifications
 */
+ (void)postNotification:(NSString *)name object:(id)object;
+ (void)postNotification:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;
- (void)postNotificationOnMainThread:(NSNotification *)notification;

/**
 * Graphics
 */
+ (CGFloat)heightForStringDrawing:(NSString *)aString withFont:(NSFont *)aFont andWidth:(CGFloat)myWidth;

/**
 * Funky
 */
+ (Class)classForName:(NSString *)className;
+ (NSArray *)allBundlesInDirectory:(NSString *)subdir withExtension:(NSString *)bundleExtension;

@end
