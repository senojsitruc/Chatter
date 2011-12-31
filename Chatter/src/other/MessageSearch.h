//
//  MessageSearch.h
//  Chatter
//
//  Created by Jones Curtis on 2011.06.23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageSearch : NSObject
{
@private
	NSArray *mMessages;
	NSString *mQuery;
	void (^mHandler)(NSArray*, NSIndexSet*);
	
	BOOL mStop;
	BOOL mStopped;
}

@property (readonly) BOOL isStopped;

- (void)searchData:(NSArray *)data withQuery:(NSString *)query inBackground:(BOOL)background andHandler:(void (^)(NSArray*, NSIndexSet*))handler;
- (void)stop;


@end
