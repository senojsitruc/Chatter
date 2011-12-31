//
//  ServiceImporter.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServiceImporterMessage <NSObject>
- (NSString *)screenname;
- (NSDate *)timestamp;
- (NSString *)timestampStr;
- (NSString *)message;
- (NSString *)sessionName;

- (void)setScreenname:(NSString *)screenname;
- (void)setTimestamp:(NSDate *)timestamp;
- (void)setTimestampStr:(NSString *)timestampStr;
- (void)setMessage:(NSString *)message;
- (void)setSessionName:(NSString *)session;
@end

typedef void (^ServiceImporterMessageCallback) (id<ServiceImporterMessage>, BOOL*);

@protocol ServiceImporter <NSObject>
+ (NSString *)name;
+ (NSArray *)supportedContentTypes;
+ (NSArray *)supportedTypeCodes;
+ (NSArray *)supportedKinds;
+ (NSArray *)supportedFileExtensions;
+ (NSArray *)supportedSearchPaths;
- (BOOL)importFileAtPath:(NSString *)filePath withMessageClass:(Class<ServiceImporterMessage>)messageClass andHandler:(ServiceImporterMessageCallback)handler;
+ (BOOL)canHandleFilePath:(NSString *)filePath;
@end

@interface ServiceImporter : NSObject
+ (void)loadImporters;
+ (NSArray *)importers;
+ (id<ServiceImporter>)importerForFilePath:(NSString *)filePath;
+ (id<ServiceImporter>)importerForName:(NSString *)importerName;
@end
