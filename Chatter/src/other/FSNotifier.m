//
//  FSNotifier.m
//  Get
//
//  Created by Curtis Jones on 2010.05.15.
//  Copyright 2010 Nexidia. All rights reserved.
//

#import "FSNotifier.h"
#import "Easy.h"

static FSNotifier *gNotifier;

NSString * const CZFSNotifierNotificationVolumeAppeared = @"CZFSNotifierNotificationVolumeAppeared";
NSString * const CZFSNotifierNotificationVolumeDisappeared = @"CZFSNotifierNotificationVolumeDisappeared";

void fsevent_callback (ConstFSEventStreamRef streamRef, FSNotifierItem *item, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]);
void da_disk_appeared_callback (DADiskRef dadisk, FSNotifierItem *item);
void da_disk_disappeared_callback (DADiskRef dadisk, FSNotifierItem *item);





@implementation FSVolume

@synthesize path = mPath;
@synthesize isNetworkVolume = mIsNetworkVolume;

@end





@implementation FSNotifierItem

@synthesize sltype = mSlType;
@synthesize slkind = mSlKind;
@synthesize slquery = mSlQuery;
@synthesize slpredicate = mSlPredicate;
@dynamic fseventstream;
@synthesize fslatency = mFsLatency;
@synthesize fspaths = mFsPaths;
@synthesize fsrealpaths = mFsRealPaths;
@dynamic daSession;
@synthesize target = mTarget;
@synthesize action = mAction;
@synthesize notifier = mNotifier;

- (id)init
{
	self = [super init];
	
	if (self) {
		mFsRealPaths = [[NSMutableDictionary alloc] initWithCapacity:10];
	}
	
	return self;
}

- (void)dealloc
{
	if (mFsEventStream != NULL) {
		FSEventStreamRelease(mFsEventStream);
		mFsEventStream = NULL;
	}
	
	if (mDaSession != NULL) {
		CFRelease(mDaSession);
		mDaSession = NULL;
	}
}

- (FSEventStreamRef)fseventstream
{
	return mFsEventStream;
}

- (void)setFseventstream:(FSEventStreamRef)stream
{
	if (mFsEventStream != NULL)
		FSEventStreamRelease(mFsEventStream);
	
	mFsEventStream = stream;
	FSEventStreamRetain(stream);
}

- (DASessionRef)daSession
{
	return mDaSession;
}

- (void)setDaSession:(DASessionRef)session
{
	if (mDaSession != NULL)
		CFRelease(mDaSession);
	
	mDaSession = session;
	CFRetain(mDaSession);
}

@end





@implementation FSNotifierEvent

@synthesize object = mObject;
@synthesize item = mItem;
@synthesize target = mTarget;
@synthesize action = mAction;


@end





@implementation FSNotifierPath

@synthesize path = mPath;
@synthesize deleted = mDeleted;
@synthesize myRetainCount = mRetainCount;
@synthesize modified = mModified;
@synthesize target = mTarget;
@synthesize action = mAction;

+ (FSNotifierPath *)pathWithPath:(NSString *)path target:(id)anObject action:(SEL)aSelector
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	FSNotifierPath *fspath = [[FSNotifierPath alloc] init];
	
	fspath.path = path;
	fspath.deleted = ![fileManager fileExistsAtPath:path];
	fspath.myRetainCount = 1;
	fspath.modified = [[[fileManager attributesOfItemAtPath:path error:nil] objectForKey:NSFileModificationDate] description];
	fspath.target = anObject;
	fspath.action = aSelector;
	
	return fspath;
}


- (BOOL)isEqual:(id)anObject
{
	if (FALSE == [anObject isKindOfClass:[FSNotifierPath class]])
		return FALSE;
	
	return [mPath isEqualToString:((FSNotifierPath*)anObject).path];
}

@end





@interface FSNotifier (PrivateMethods)
- (void)postNotification:(NSObject *)object forItem:(FSNotifierItem *)item target:(id)anObject action:(SEL)aSelector;;
- (void)volumeAppeared:(NSDictionary *)attributes;
- (void)volumeDisappeared:(NSDictionary *)attributes;
@end

@implementation FSNotifier

@synthesize volumeMonitor = mVolumeMonitor;

/**
 *
 *
 */
+ (void)initialize
{
	gNotifier = [[FSNotifier alloc] init];
}

/**
 *
 *
 */
+ (FSNotifier *)mainInstance
{
	return gNotifier;
}

/**
 *
 *
 */
- (id)init
{
	self = [super init];
	
	if (self) {
		mStop = FALSE;
		mItemDict = [[NSMutableDictionary alloc] initWithCapacity:100];
		mQueryDict = [[NSMutableDictionary alloc] initWithCapacity:100];
		mEventQueue = [[NSMutableArray alloc] initWithCapacity:1000];
		mVolumes = [[NSMutableDictionary alloc] initWithCapacity:100];
		mEventSem = dispatch_semaphore_create(0);
		
		[NSThread detachNewThreadSelector:@selector(eventLoop) toTarget:self withObject:nil];
	}
	
	return self;
}

/**
 *
 *
 */
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	dispatch_release(mEventSem);
}





#pragma mark -
#pragma mark Accessors

/**
 *
 *
 */
- (void)stop
{
	mStop = TRUE;
	dispatch_semaphore_signal(mEventSem);
}





#pragma mark -
#pragma mark Spotlight

/**
 *
 *
 */
- (void)addObserverForType:(NSString *)type andKind:(NSString *)kind target:(id)anObject action:(SEL)aSelector
{
	FSNotifierItem *item = [[FSNotifierItem alloc] init];
	
	// allocate the metadata query and the predicate. the predicate is initialized with the search
	// parameters: a file type and file kind.
	item.sltype = type;
	item.slkind = kind;
	item.slquery = [[NSMetadataQuery alloc] init];
	item.target = anObject;
	item.action = aSelector;
	
	// construct the search query based on whether both a type and kind are specified or if just one
	// of the two is specified. if the caller passes a zero-length string, then they're just being 
	// annoying and this won't work at all.
	if (type && kind)
		item.slpredicate = [NSPredicate predicateWithFormat:@"(kMDitemFSTypeCode == %@) OR (kMDItemKind == %@)", type, kind];
	else if (type)
		item.slpredicate = [NSPredicate predicateWithFormat:@"(kMDitemFSTypeCode == %@)", type];
	else if (kind)
		item.slpredicate = [NSPredicate predicateWithFormat:@"(kMDItemKind == %@)", kind];
	else
		NSLog(@"%s.. no type or kind specified. that was stupid. whatever.", __PRETTY_FUNCTION__);
	
	// add our observer for search results for this spotlight query
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doNotificationQuery:) name:nil object:item.slquery];
	
	// store the item object keyed on the extension string. we need the mItemDict entry for recalling
	// a query by type and kind. we need the mQueryDict entry for recalling a query during a search
	// callback.
	@synchronized (mItemDict) {
		[mItemDict setObject:item forKey:[NSString stringWithFormat:@"%@:%@", item.sltype, item.slkind]];
		[mQueryDict setObject:item forKey:[item.slpredicate predicateFormat]];
	}
	
	// configure the metadata query: sort ascending (not really very important), only search local
	// volumes and not network volumes (very important), pass in the predicate, set the search
	// interval to only bug us once every five seconds (at most) and start the query.
	[item.slquery setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:TRUE]]];
	[item.slquery setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryLocalComputerScope]];
	[item.slquery setPredicate:item.slpredicate];
	[item.slquery setNotificationBatchingInterval:5.0];
	[item.slquery startQuery];
	
}

/**
 * Stops the query, removes and deallocates the underlying objects.
 *
 */
- (void)removeObserverForType:(NSString *)type andKind:(NSString *)kind
{
	FSNotifierItem *item = nil;
	NSString *key = [NSString stringWithFormat:@"%@:%@", type, kind];
	
	@synchronized (mItemDict) {
		item = [mItemDict objectForKey:key];
		[mItemDict removeObjectForKey:key];
		[mQueryDict removeObjectForKey:[[item.slquery predicate] predicateFormat]];
	}
	
	[item.slquery stopQuery];
}





#pragma mark -
#pragma mark FSEvents

/**
 *
 *
 */
- (void)addObserverForPath:(NSString *)path target:(id)anObject action:(SEL)aSelector
{
	//NSLog(@"%s.. path=%@", __PRETTY_FUNCTION__, path);
	
	FSNotifierItem *item = nil;
	FSNotifierPath *fspath = nil;
	struct FSEventStreamContext context;
	NSString *parent = nil;
	
	// remove the directory indicator from the path if there is one
	if (TRUE == [path hasSuffix:@"/"])
		path = [path substringToIndex:[path length]-1];
	
	// fsevents are based on the contents of the target. if the target itself is moved/modified, that
	// won't trigger an event. so, we need to watch from the perspective of the parent directory.
	parent = [path stringByDeletingLastPathComponent];
	
	// we need this for recalling the item by the path. if the parent directory is already being
	// observed, add this (presumably) new sub-dir of the parent directory to the list. this is our
	// way of doing retain counts on the parent directory observer. when the last sub-dir is removed
	// then we know to stop observing the parent directory.
	@synchronized (mItemDict) {
		if (nil != (item = [mItemDict objectForKey:parent])) {
			if (nil != (fspath = [item.fsrealpaths objectForKey:path]))
				fspath.myRetainCount = fspath.myRetainCount + 1;
			else
				[item.fsrealpaths setObject:[FSNotifierPath pathWithPath:path target:anObject action:aSelector] forKey:path];
			goto done;
		}
		
		[mItemDict setObject:(item = [[FSNotifierItem alloc] init]) forKey:parent];
		[item.fsrealpaths setObject:[FSNotifierPath pathWithPath:path target:anObject action:aSelector] forKey:path];
	}
	
	// configure the context struct, which lets the fsevents system pass us the FSNotifierItem object
	// to our callback. this is a good thing.
	memset(&context, 0, sizeof(context));
	context.version = 0;
	context.info = (__bridge void *)item;
	context.retain = NULL;
	context.release = NULL;
	context.copyDescription = NULL;
	
	// configure the NSNotifierItem
	item.fspaths = [NSArray arrayWithObject:parent];
	item.fslatency = 1.0;
	item.fseventstream = FSEventStreamCreate(kCFAllocatorDefault, (FSEventStreamCallback)fsevent_callback, &context, (__bridge CFArrayRef)item.fspaths, kFSEventStreamEventIdSinceNow, item.fslatency, kFSEventStreamCreateFlagNone);
	
	// start the event stream
	FSEventStreamScheduleWithRunLoop(item.fseventstream, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
	FSEventStreamStart(item.fseventstream);
	
	//NSLog(@"%s.. observing '%@' for '%@'", __PRETTY_FUNCTION__, parent, [path lastPathComponent]);
	
done:
	;
}

/**
 * Removes the observer for a particular path. However, since we actually observe the parent of a
 * target path, we only want to remove the observer if the last sub-dir has been removed. And that's
 * precisely what we do.
 *
 */
- (void)removeObserverForPath:(NSString *)path
{
	FSNotifierItem *item = nil;
	FSNotifierPath *fspath = nil;
	NSString *parent = [path stringByDeletingLastPathComponent];
	
	@synchronized (mItemDict) {
		item = [mItemDict objectForKey:parent];
		fspath = [item.fsrealpaths objectForKey:path];
		
		if (fspath.myRetainCount > 1)
			fspath.myRetainCount = fspath.myRetainCount - 1;
		else
			[item.fsrealpaths removeObjectForKey:path];
		
		if ([item.fsrealpaths count] == 0) {
			[mItemDict removeObjectForKey:parent];
			FSEventStreamStop(item.fseventstream);
			FSEventStreamInvalidate(item.fseventstream);
		}
	}
	
}

/**
 *
 *
 */
- (void)postNotification:(NSObject *)object forItem:(FSNotifierItem *)item target:(id)anObject action:(SEL)aSelector
{
	//NSLog(@"%s.. object=%@", __PRETTY_FUNCTION__, object);
	
	@synchronized (mEventQueue) {
		if ([mEventQueue count] >= 10000)
			return;
		
		FSNotifierEvent *event = [[FSNotifierEvent alloc] init];
		
		event.object = object;
		event.item = item;
		event.target = anObject;
		event.action = aSelector;
		
		[mEventQueue addObject:event];
		
		if ([mEventQueue count] == 1)
			dispatch_semaphore_signal(mEventSem);
	}
}





#pragma mark -
#pragma mark Disk Arbitration

/**
 *
 *
 */
- (void)enableVolumeMonitoring
{
	FSNotifierItem *item = [[FSNotifierItem alloc] init];
	
	item.notifier = self;
	item.daSession = DASessionCreate(kCFAllocatorDefault);
	
	if (item.daSession == nil) {
		NSLog(@"%s.. failed to DASessionCreate()", __PRETTY_FUNCTION__);
		return;
	}
	
	// register to receive notifications when volumes mount/unmount
	DARegisterDiskAppearedCallback(item.daSession, NULL, (DADiskAppearedCallback)da_disk_appeared_callback, (__bridge void *)item);
	DARegisterDiskDisappearedCallback(item.daSession, NULL, (DADiskDisappearedCallback)da_disk_disappeared_callback, (__bridge void *)item);
	DASessionScheduleWithRunLoop(item.daSession, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
	
	// there's an implict retain on DASessionCreate(), obviously, and then we retain it when we store
	// it via setDaSession:, so we need to release one retain.
	CFRelease(item.daSession);
	
	// set the volume monitoring object for this FSNotifier
	self.volumeMonitor = item;
	
	// we retain it when we store it, so we need to release it now
}

/**
 *
 *
 */
- (void)disableVolumeMonitoring
{
	FSNotifierItem *item = self.volumeMonitor;
	
	// unregister for the mount/unmount notifications
	DAUnregisterCallback(item.daSession, (DADiskAppearedCallback)da_disk_appeared_callback, (__bridge void *)item);
	DAUnregisterCallback(item.daSession, (DADiskDisappearedCallback)da_disk_disappeared_callback, (__bridge void *)item);
	
	self.volumeMonitor = nil;
}

/**
 *
 *
 */
- (void)volumeAppeared:(NSDictionary *)attributes
{
	FSVolume *fsvolume = [[FSVolume alloc] init];
	NSURL *path = nil;
	CFBooleanRef network = nil;
	
	/*
	for (NSObject *key in attributes) {
		NSLog(@"  %@ = [%@] %@", key, [[attributes objectForKey:key] class], [attributes objectForKey:key]);
	}
	*/
	
	// don't continue if this notification doesn't include a volume path. this can occur when the 
	// notification is for a "whole disk" instead of a partition; or a disk image
	if (nil == (path = [attributes objectForKey:@"DAVolumePath"]))
		return;
	
	// don't continue if this notification doesn't include an indication of whether this is a network
	// volume.
	if (nil == (network = (__bridge CFBooleanRef)[attributes objectForKey:@"DAVolumeNetwork"]))
		return;
	
	// gather the attributes of the volume that we're interested in
	fsvolume.path = [path path];
	fsvolume.isNetworkVolume = (network == kCFBooleanTrue);
	
	// add the volume to our list of volumes
	@synchronized (mVolumes) {
		[mVolumes setObject:fsvolume forKey:fsvolume.path];
	}
	
	// post a notification that the volume appeared, to anyone who might be interested
	[Easy postNotification:CZFSNotifierNotificationVolumeAppeared object:fsvolume];
	
}

/**
 *
 *
 */
- (void)volumeDisappeared:(NSDictionary *)attributes
{
	NSURL *path = nil;
	FSVolume *fsvolume = nil;
	
	/*
	for (NSObject *key in attributes) {
		NSLog(@"  %@ = [%@] %@", key, [[attributes objectForKey:key] class], [attributes objectForKey:key]);
	}
	*/
	
	// don't continue if this notification doesn't include a volume path. this can occur when the 
	// notification is for a "whole disk" instead of a partition; or a disk image
	if (nil == (path = [attributes objectForKey:@"DAVolumePath"]))
		return;
	
	// remove the volume from our list of volumes
	@synchronized (mVolumes) {
		fsvolume = [mVolumes objectForKey:[path path]];
		[mVolumes removeObjectForKey:[path path]];
	}
	
	// post a notification that the volume appeared, to anyone who might be interested
	[Easy postNotification:CZFSNotifierNotificationVolumeDisappeared object:fsvolume];
	
}

/**
 *
 *
 */
- (FSVolume *)volumeForPath:(NSString *)path
{
	FSVolume *fsvolume = nil;
	
	@synchronized (mVolumes)
	{
		if (nil != (fsvolume = [mVolumes objectForKey:path]))
			return fsvolume;
		
		for (NSString *mountPoint in mVolumes) {
			if ([path hasPrefix:mountPoint])
				if (fsvolume == nil || [mountPoint length] > [fsvolume.path length])
					fsvolume = [mVolumes objectForKey:mountPoint];
		}
	}
	
	return fsvolume;
}

/**
 *
 *
 */
void
da_disk_appeared_callback (DADiskRef dadisk, FSNotifierItem *item)
{
	[item.notifier volumeAppeared:(__bridge_transfer NSDictionary *)DADiskCopyDescription(dadisk)];
}

/**
 *
 *
 */
void
da_disk_disappeared_callback (DADiskRef dadisk, FSNotifierItem *item)
{
	[item.notifier volumeDisappeared:(__bridge_transfer NSDictionary *)DADiskCopyDescription(dadisk)];
}





#pragma mark -
#pragma mark Callbacks & Notifications

/**
 *
 *
 */
void
fsevent_callback (ConstFSEventStreamRef streamRef,
                  FSNotifierItem *item,
                  size_t numEvents,
                  void *eventPaths,
                  const FSEventStreamEventFlags eventFlags[],
                  const FSEventStreamEventId eventIds[])
{
	int i;
	char **paths = eventPaths;
	NSString *observedPath = nil;
	NSFileManager *fileManager = nil;
	NSMutableDictionary *fspaths = [NSMutableDictionary dictionary];
	
	if (item == nil)
		return;
	
	fileManager = [[NSFileManager alloc] init];
	observedPath = [item.fspaths objectAtIndex:0];
	
	// the "work flow" is outlined below. the bulk of it is divided into two sections: (1) events
	// pertaining to the immediate contents of the observed path and (2) events pertaining to some
	// sub-directory of the observed path.
	//
	// we have to make this distinction because we need to know when a "real path" (ie, one of the
	// paths that the user called addObserver() for) is deleted/renamed or magically reappears after
	// previously having been deleted/renamed.
	//
	// otherwise, we just look for the "real path" that is a parent of the event path. yes, it is 
	// possible to have a watchfolder that is itself a sub-directory of another watchfolder ... so,
	// which watchfolder should get the event? it doesn't matter. either way the file is processed
	// and updated (if necessary).
	//
	// okay I'm done rambling now. the work flow:
	//
	// for each event path
	//   if the event path is equal to our observed path
	//     for each real path
	//       if the observed path exists (but previously didn't) or doesn't exist (but previously did)
	//         update observed path "deleted" state
	//         post a notification
	//         break;
	//   else
	//     for each real path
	//       if the real path is a prefix on the event path
	//         past a notification
	//         break
	//
	for (i = 0; i < numEvents; ++i) {
		NSString *path = [NSString stringWithCString:paths[i] encoding:NSUTF8StringEncoding];
		
		if (TRUE == [path hasSuffix:@"/"])
			path = [path substringToIndex:[path length]-1];
		
		//NSLog(@"path=%@, observed=%@", path, observedPath);
		
		if ([path isEqualToString:observedPath]) {
			for (NSString *realpath in item.fsrealpaths) {
				FSNotifierPath *fspath = [item.fsrealpaths objectForKey:realpath];
				BOOL exists = [fileManager fileExistsAtPath:fspath.path];
				NSString *modified = [[[fileManager attributesOfItemAtPath:fspath.path error:nil] objectForKey:NSFileModificationDate] description];
				
				if (exists) {
					if (!fspath.deleted && [modified isEqualToString:fspath.modified])
						continue;
				}
				else if (fspath.deleted)
					continue;
				
				fspath.modified = modified;
				fspath.deleted = !exists;
//			[[FSNotifier mainInstance] postNotification:fspath.path forItem:item target:fspath.target action:fspath.action];
				[fspaths setObject:fspath forKey:fspath.path];
				
				break;
			}
		}
		else {
			for (NSString *realpath in item.fsrealpaths) {
				FSNotifierPath *fspath = [item.fsrealpaths objectForKey:realpath];
				
				if (FALSE == [path hasPrefix:fspath.path])
					continue;
				
				fspath.deleted = FALSE;
//			[[FSNotifier mainInstance] postNotification:realpath forItem:item target:fspath.target action:fspath.action];
				[fspaths setObject:fspath forKey:fspath.path];
				
				break;
			}
		}
	}
	
	for (FSNotifierPath *fspath in [fspaths allValues])
		[[FSNotifier mainInstance] postNotification:fspath.path forItem:item target:fspath.target action:fspath.action];
	
}

/**
 * Called during a Spotlight search when the state of the search changes (ie, started, finished,
 * working, updated).
 *
 */
- (void)doNotificationQuery:(NSNotification*)notification
{
	// the search has started; don't do anything
	if ([[notification name] isEqualToString:NSMetadataQueryDidStartGatheringNotification]) {
		//NSLog(@"%s.. started", __PRETTY_FUNCTION__);
	}
	
	// the search has finished or was updated; process the results
	else if ([[notification name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification] ||
	         [[notification name] isEqualToString:NSMetadataQueryDidUpdateNotification])
	{
		//NSLog(@"%s.. finished [%d]", __PRETTY_FUNCTION__, [[(NSMetadataQuery*)[notification object] results] count]);
		
		NSMetadataQuery *query = (NSMetadataQuery *)[notification object];
		FSNotifierItem *item = [mQueryDict objectForKey:[[query predicate] predicateFormat]];
		NSArray *results = [query results];
		
		[query disableUpdates];
		
		if (item && item.target && item.action)
			for (NSMetadataItem *mitem in results)
				[[FSNotifier mainInstance] postNotification:mitem forItem:item target:item.target action:item.action];
		
		[query enableUpdates];
	}
	
	// the search is working; don't do anything
	else if ([[notification name] isEqualToString:NSMetadataQueryGatheringProgressNotification]) {
		//NSLog(@"%s.. working", __PRETTY_FUNCTION__);
	}
	
	// some unknown notification state
	else
		NSLog(@"%s.. unknown [%@]", __PRETTY_FUNCTION__, [notification name]);
}





#pragma mark - Thread

/**
 *
 *
 */
- (void)eventLoop
{
	@autoreleasepool {
		FSNotifierEvent *event = nil;
		
		while (!mStop) {
			@autoreleasepool {
			
				@synchronized (mEventQueue) {
					if ([mEventQueue count] != 0) {
						event = [mEventQueue objectAtIndex:0];
						[mEventQueue removeObjectAtIndex:0];
					}
				}
				
				if (event == nil) {
					dispatch_semaphore_wait(mEventSem, DISPATCH_TIME_FOREVER);
					continue;
				}
				
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
				[event.target performSelector:event.action withObject:event.item withObject:event.object];
#pragma clang diagnostic pop
				event = nil;
			}
		}
	
	}
}

@end
