//
//  MetadataSearch.h
//  Chatter
//
//  Created by Jones Curtis on 2011.07.07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MetadataSearchHandler)(NSArray*, BOOL*);

@interface MetadataSearch : NSObject
{
@private
	NSMetadataQuery *mQuery;
	NSPredicate *mPredicate;
	
	BOOL mIsDone;
	
	NSString *mContentType;
	NSString *mTypeCode;
	NSString *mKind;
	NSString *mName;
	
	MetadataSearchHandler mHandler;
}

@property (readonly) BOOL isDone;
@property (readwrite, strong) NSString *contentType;
@property (readwrite, strong) NSString *typeCode;
@property (readwrite, strong) NSString *kind;
@property (readwrite, strong) NSString *name;
@property (readwrite, weak) MetadataSearchHandler handler;

+ (id)searchByContentType:(NSString *)contentType andTypeCode:(NSString *)typeCode andKind:(NSString *)kind andName:(NSString *)name withHandler:(MetadataSearchHandler)handler;

- (void)start:(id)sender;
- (void)stop;

@end
