//
//  FSNotifier.h
//  Get
//
//  Created by Curtis Jones on 2010.05.15.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <DiskArbitration/DADisk.h>
#import <DiskArbitration/DADissenter.h>
#import <DiskArbitration/DASession.h>
#import <DiskArbitration/DiskArbitration.h>

extern NSString * const CZFSNotifierNotificationVolumeAppeared;
extern NSString * const CZFSNotifierNotificationVolumeDisappeared;

@class FSNotifier;





@interface FSVolume : NSObject
{
	NSString *mPath;                  // /Volumes/VolumeName/
	BOOL mIsNetworkVolume;            // is network volume
}

@property (readwrite, retain) NSString *path;
@property (readwrite, assign) BOOL isNetworkVolume;

@end





@interface FSNotifierItem : NSObject
{
	/* spotlight */
	NSString *mSlType;                // spotlight - kMDitemFSTypeCode
	NSString *mSlKind;                // spotlight - kMDItemKind
	NSMetadataQuery *mSlQuery;        // spotlight - metadata query
	NSPredicate *mSlPredicate;        // spotlight - predicate
	
	/* fsevents */
	FSEventStreamRef mFsEventStream;  // fsevents - event stream
	CFTimeInterval mFsLatency;        // fsevents - latency
	NSArray *mFsPaths;                // fsevents - paths (parent directory of target)
	NSMutableDictionary *mFsRealPaths;// fsevents - the target directories
	
	/* disk arbitration */
	DASessionRef mDaSession;          // disk abritration - session
	
	/* callback */
	id mTarget;                       // callback object
	SEL mAction;                      // callback selector
	
	/* other */
	FSNotifier *mNotifier;            // weak reference to an FSNotifier
}

@property (readwrite, retain) NSString *sltype;
@property (readwrite, retain) NSString *slkind;
@property (readwrite, retain) NSMetadataQuery *slquery;
@property (readwrite, retain) NSPredicate *slpredicate;
@property (readwrite, assign) FSEventStreamRef fseventstream;
@property (readwrite, assign) CFTimeInterval fslatency;
@property (readwrite, retain) NSArray *fspaths;
@property (readonly) NSMutableDictionary *fsrealpaths;
@property (readwrite, assign) DASessionRef daSession;
@property (readwrite, assign) id target;
@property (readwrite, assign) SEL action;
@property (readwrite, assign) FSNotifier *notifier;

@end





@interface FSNotifierEvent : NSObject
{
	NSObject *mObject;                // a string path or an NSMetadataItem
	FSNotifierItem *mItem;            // FSNotifierItem;
	id mTarget;                       // callback object
	SEL mAction;                      // callback selector
}

@property (readwrite, retain) NSObject *object;
@property (readwrite, retain) FSNotifierItem *item;
@property (readwrite, assign) id target;
@property (readwrite, assign) SEL action;

@end





@interface FSNotifierPath : NSObject
{
	NSString *mPath;                  // path
	BOOL mDeleted;                    // path was noted to be missing
	NSString *mModified;              // file modification date
	NSUInteger mRetainCount;          // retain count
	id mTarget;                       // callback object
	SEL mAction;                      // callback selector
}

@property (readwrite, retain) NSString *path;
@property (readwrite, assign) BOOL deleted;
@property (readwrite, assign) NSUInteger retainCount;
@property (readwrite, retain) NSString *modified;
@property (readwrite, assign) id target;
@property (readwrite, assign) SEL action;

+ (FSNotifierPath *)pathWithPath:(NSString *)path target:(id)anObject action:(SEL)aSelector;

@end





@interface FSNotifier : NSObject
{
	FSNotifierItem *mVolumeMonitor;   // FSNotifierItem for volume monitoring
	NSMutableDictionary *mItemDict;   // FSNotifierItem objects keyed on the path/extension
	NSMutableDictionary *mQueryDict;  // FSNotifierItem objects keyed on the predicate format
	NSMutableArray *mEventQueue;      // FSNotifierEvent objects
	dispatch_semaphore_t mEventSem;   // semaphore for mEventQueue
	BOOL mStop;                       // stop the event thread
	NSMutableDictionary *mVolumes;    // FSVolume objects keyed on the volume mount point
}

@property (readwrite, retain) FSNotifierItem *volumeMonitor;

/**
 *
 */
+ (FSNotifier *)mainInstance;

/**
 *
 */
- (void)stop;

/**
 * Add an observer that will receive a callback whenever a file of the specified type (ie, "FCPF") 
 * and/or kind (ie, "Final Cut Pro Project File") is created / deleted / modified. Don't forget to
 * removeObserverForType:andKind: when you're done.
 *
 * Pass nil for the argument (type, kind) that you don't want included as a search parameter. If you
 * pass a zero-length string the behavior is undefined. You've been warned.
 *
 */
- (void)addObserverForType:(NSString *)type andKind:(NSString *)kind target:(id)anObject action:(SEL)aSelector;

/**
 *
 */
- (void)removeObserverForType:(NSString *)type andKind:(NSString *)kind;

/**
 * Add an observer that will receive a callback whenever a file or directory is modified within the
 * specified directory. The callback will not be notified when the specified directory is changed.
 * If you want to know when a given directory changes, you must specified the directory's parent as
 * the path to this function; and filter out the unrelated events for the other files / directories
 * within that parent directory.
 *
 * Don't forget to removeObserverForPath: when you're done.
 *
 */
- (void)addObserverForPath:(NSString *)path target:(id)anObject action:(SEL)aSelector;

/**
 *
 */
- (void)removeObserverForPath:(NSString *)path;

/**
 *
 */
- (void)enableVolumeMonitoring;

/**
 *
 */
- (void)disableVolumeMonitoring;

/**
 * Returns the most specific volume for the given path.
 */
- (FSVolume *)volumeForPath:(NSString *)path;

@end
