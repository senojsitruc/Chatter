//
//  ImportController.m
//  Chatter
//
//  Created by Jones Curtis on 2011.07.07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImportController.h"
#import "ProgressSheetController.h"
#import "Easy.h"
#import "DBConnection.h"
#import "ChatterAccount+DBObject.h"
#import "ChatterMessage+DBObject.h"
#import "ChatterMessageWord+DBObject.h"
#import "ChatterPerson+DBObject.h"
#import "ChatterSession+DBObject.h"
#import "ChatterSetting+DBObject.h"
#import "ChatterSource+DBObject.h"
#import "ChatterSessionAccount+DBObject.h"
#import "ChatterWord+DBObject.h"
#import "ChatterObjectCache.h"
#import "MetadataSearch.h"
#import "ServiceImporter.h"
#import "Stemmer.h"
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/ABAddressBookC.h>
#import <AddressBook/ABTypedefs.h>
#import <AddressBook/ABGlobals.h>
#import <AddressBook/ABImageLoading.h>
#import <AddressBook/ABPerson.h>

@interface ImportController (PrivateMethods)
- (void)doActionImportMagical;
- (void)doActionImportManual;
- (void)importFile:(NSString *)filePath importer:(id<ServiceImporter>)importer;
@end

@implementation ImportController





/**
 *
 *
 */
- (void)awakeFromNib
{
	// signifies whether we have loaded the pop-up button in the open-panel with the importers
	mManualDidLoadTypes = FALSE;
	
	// set the default import directory
	mLastImportUrl = [[NSURL alloc] initWithString:[[Easy pathToDocumentsDirectory] stringByAppendingPathComponent:@"iChats"]];
	
	// select the "automatically determine appropriate importer" item in the importers list
	[mManualTypeBtn selectItemWithTag:1];
	
	[mMagicalPrg setHidden:TRUE];
	[mMagicalPrg stopAnimation:nil];
	
	mData = [[NSMutableArray alloc] init];
	mDataByService = [[NSMutableDictionary alloc] init];
}





#pragma mark - Callbacks

/**
 * Grey out the buttons, show the progress indicator and start the search.
 *
 */
- (IBAction)doActionMagicalOkay:(id)sender
{
	mStop = TRUE;
	
	[NSApp endSheet:mMagicalWindow];
	
	[mProgressSheetController setTitle:@"Importing chat logs. Please wait...."];
	[mProgressSheetController setSubtitle:@""];
	[mProgressSheetController setIndeterminateMode];
	[mProgressSheetController performSelectorOnMainThread:@selector(showInWindow:) withObject:mParentWindow waitUntilDone:FALSE];
	
	mImportFileName = nil;
	mImportDone = FALSE;
	
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doActionImportUpdateProgress:) userInfo:nil repeats:TRUE];
	[NSThread detachNewThreadSelector:@selector(magicalSearchImportThread) toTarget:self withObject:nil];
}

/**
 * Hide the window. We're done.
 *
 */
- (IBAction)doActionMagicalCancel:(id)sender
{
	mStop = TRUE;
	[NSApp endSheet:mMagicalWindow];
}

/**
 *
 *
 */
- (void)magicalSearchFindThread
{
	@autoreleasepool {
		NSMutableArray *searches = [NSMutableArray array];
		NSMutableDictionary *searchPaths = [NSMutableDictionary dictionary];
		
		//
		// handle a file path
		//
		void (^handleFilePath)(NSString*, NSString*) = ^ (NSString *serviceName, NSString *path) {
			NSMutableDictionary *serviceInfo = [mDataByService objectForKey:serviceName];
			NSMutableDictionary *serviceFiles = [serviceInfo objectForKey:@"Files"];
			
			if (serviceInfo == nil) {
				[mDataByService setObject:(serviceInfo = [NSMutableDictionary dictionary]) forKey:serviceName];
				[serviceInfo setObject:[NSNumber numberWithInteger:NSOnState] forKey:@"State"];
				[serviceInfo setObject:[NSNumber numberWithInteger:0] forKey:@"Count"];
				[serviceInfo setObject:(serviceFiles = [NSMutableDictionary dictionary]) forKey:@"Files"];
				@synchronized (mData) { [mData addObject:serviceName]; }
			}
			
			[serviceFiles setObject:path forKey:path];
			
			@synchronized (serviceInfo) {
				[serviceInfo setObject:[NSNumber numberWithInteger:[serviceFiles count]] forKey:@"Count"];
			}
			
			[mMagicalTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:FALSE];
		};
		
		//
		// handle a set of metadata items
		//
		void (^handleMetadataResults)(NSString*, NSArray*) = ^ (NSString *serviceName, NSArray *metadataItems) {
			NSMutableDictionary *serviceInfo = [mDataByService objectForKey:serviceName];
			NSMutableDictionary *serviceFiles = [serviceInfo objectForKey:@"Files"];
			
			if (serviceInfo == nil) {
				[mDataByService setObject:(serviceInfo = [NSMutableDictionary dictionary]) forKey:serviceName];
				[serviceInfo setObject:[NSNumber numberWithInteger:NSOnState] forKey:@"State"];
				[serviceInfo setObject:[NSNumber numberWithInteger:0] forKey:@"Count"];
				[serviceInfo setObject:(serviceFiles = [NSMutableDictionary dictionary]) forKey:@"Files"];
				@synchronized (mData) { [mData addObject:serviceName]; }
			}
			
			for (NSMetadataItem *metadataItem in metadataItems) {
				NSString *path = [metadataItem valueForAttribute:NSMetadataItemPathKey];
				[serviceFiles setObject:path forKey:path];
			}
			
			@synchronized (serviceInfo) {
				[serviceInfo setObject:[NSNumber numberWithInteger:[serviceFiles count]] forKey:@"Count"];
			}
			
			[mMagicalTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:FALSE];
		};
		
		for (id<ServiceImporter> importer in [ServiceImporter importers]) {
			Class importerClass = [importer class];
			NSArray *contentTypes = [importerClass supportedContentTypes];
			NSArray *typeCodes = [importerClass supportedTypeCodes];
			NSArray *kinds = [importerClass supportedKinds];
			NSArray *extensions = [importerClass supportedFileExtensions];
			NSArray *_searchPaths = [importerClass supportedSearchPaths];
			NSString *contentType=nil, *typeCode=nil, *kind=nil, *extension=nil;
			
			if (_searchPaths) {
				for (NSString *searchPath in _searchPaths) {
					[searchPaths setObject:importer forKey:searchPath];
				}
			}
			
			if ([contentTypes count] != 0)
				contentType = [contentTypes objectAtIndex:0];
			
			if ([typeCodes count] != 0)
				typeCode = [typeCodes objectAtIndex:0];
			
			if ([kinds count] != 0)
				kind = [kinds objectAtIndex:0];
			
			if ([extensions count] != 0)
				extension = [@"*." stringByAppendingString:[extensions objectAtIndex:0]];
			
			if (contentType || typeCode || kind || extension) {
				[searches addObject:[MetadataSearch searchByContentType:contentType andTypeCode:typeCode andKind:kind andName:extension withHandler:(^ (NSArray *metadataItems, BOOL *stop) {
					handleMetadataResults([[importer class] name], metadataItems);
				})]];
			}
		}
		
		for (NSString *searchPath in [searchPaths allKeys]) {
			id<ServiceImporter> importer = [searchPaths objectForKey:searchPath];
			
			[Easy iterateDirectory:[searchPath stringByExpandingTildeInPath] withHandle:(^ (NSString *path) {
				if ([[importer class] canHandleFilePath:path])
					handleFilePath([[importer class] name], path);
			})];
		}
		
		// stall until all of the searches are complete
		while (!mStop && [searches count] != 0) {
			[searches filterUsingPredicate:[NSPredicate predicateWithBlock:^ BOOL (id evaluatedObject, NSDictionary *bindings) {
				return !((MetadataSearch *)evaluatedObject).isDone;
			}]];
			
			usleep(100000);
		}
		
		if ([searches count] != 0) {
			for (MetadataSearch *search in searches)
				[search stop];
		}
		
		[self performSelectorOnMainThread:@selector(magicalSearchDone) withObject:nil waitUntilDone:FALSE];
	}
}

/**
 *
 *
 */
- (void)magicalSearchDone
{
	[mMagicalPrg stopAnimation:self];
	[mMagicalPrg setHidden:TRUE];
	[mMagicalOkayBtn setEnabled:TRUE];
}

/**
 *
 *
 */
- (void)magicalSearchImportThread
{
	@autoreleasepool {
#ifdef CHATTER_DEMO
		ChatterObjectCache *cache = [ChatterObjectCache sharedInstance];
#endif
		NSUInteger filesTotal = 0;
		
		for (NSString *serviceName in [mDataByService  allKeys]) {
			NSDictionary *serviceInfo = [mDataByService objectForKey:serviceName];
			
			if (NSOnState != [[serviceInfo objectForKey:@"State"] integerValue])
				continue;
			
			filesTotal += [[serviceInfo objectForKey:@"Count"] integerValue];
		}
		
		mImportFilesTotal = filesTotal;
		mImportImporting = TRUE;
		mImportScanning = FALSE;
		
		for (NSString *serviceName in [mDataByService  allKeys]) {
			@autoreleasepool {
				NSDictionary *serviceInfo = [mDataByService objectForKey:serviceName];
				id<ServiceImporter> importer = [ServiceImporter importerForName:serviceName];
				
				if (NSOnState == [[serviceInfo objectForKey:@"State"] integerValue]) {
					for (NSString *filePath in [[serviceInfo objectForKey:@"Files"] allValues]) {
						mImportFilesDone += 1;
						[self importFile:filePath importer:importer];
						
						// this check stops an import after the message count reaches 10,000, but it's placement allows
						// a user to continue to import one file at a time thereafter.
#ifdef CHATTER_DEMO
						if ([cache messageCount] >= 10000) {
							[pool2 release];
							goto done;
						}
#endif
					}
				}
			
			}
		}
		
done:
		// clean up and cause the progress sheet to finish
		{
			mImportFileName = nil;
			mImportDone = TRUE;
		}
		
	}
}




#pragma mark - Accessors

/**
 *
 *
 */
- (void)showInWindow:(NSWindow *)window
{
	mStop = FALSE;
	
	[mData removeAllObjects];
	[mDataByService removeAllObjects];
	
	mParentWindow = window;
	
	// clear out previously used data
	[mData removeAllObjects];
	
	NSAlert *alert = [NSAlert alertWithMessageText:@"Would you like to manually find the files you want to import or let Chatter magically find all of the supported chat logs on your system?"
																	 defaultButton:@"Magical"
																 alternateButton:@"Manual"
																		 otherButton:@"Cancel"
											 informativeTextWithFormat:@"You will have an opportunity to review the results before importing the files."];
	[alert beginSheetModalForWindow:mParentWindow modalDelegate:self didEndSelector:@selector(doActionImportSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

/**
 *
 *
 */
- (void)doActionImportSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[[alert window] orderOut:self];
	
	if (NSAlertDefaultReturn == returnCode)
		[self doActionImportMagical];
	else if (NSAlertAlternateReturn == returnCode)
		[self doActionImportManual];
}

/**
 *
 *
 */
- (void)doActionImportMagical
{
	[NSApp beginSheet:mMagicalWindow modalForWindow:mParentWindow modalDelegate:self didEndSelector:@selector(doActionMagicalSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
	
	[mMagicalPrg setHidden:FALSE];
	[mMagicalPrg startAnimation:self];
	[mMagicalOkayBtn setEnabled:TRUE];
	
	[NSThread detachNewThreadSelector:@selector(magicalSearchFindThread) toTarget:self withObject:nil];
}

/**
 *
 *
 */
- (void)doActionMagicalSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[sheet orderOut:self];
}

/**
 * Show an open-file dialog; let the user select the files and directories he wants to import; then
 * perform the import while a progress sheet shows our progress.
 *
 * TODO: allowed file types for the open-panel should be derived from asking each known importer
 *       what file types it supports.
 *
 */
- (void)doActionImportManual
{
	NSOpenPanel *panel = mManualOpenPanel = [NSOpenPanel openPanel];
	
	[panel setCanChooseFiles:TRUE];
	[panel setCanChooseDirectories:TRUE];
	[panel setResolvesAliases:TRUE];
	[panel setAllowsMultipleSelection:TRUE];
	[panel setMessage:@"Select the files and directories you wish to import."];
	[panel setAllowedFileTypes:[NSArray arrayWithObjects:@"ichat", @"chatlog", @"xml", @"html", @"dbb", @"txt", @"colloquyTranscript", @"info.colloquy.transcript", @"com.adiumx.xmllog", @"com.apple.ichat.transcript", nil]];
	[panel setAccessoryView:mManualAccessoryView];
	[panel setDirectoryURL:mLastImportUrl];
	
	if (!mManualDidLoadTypes) {
		NSArray *importers = [[ServiceImporter importers] sortedArrayUsingComparator:(^ NSComparisonResult (id obj1, id obj2) {
			return [[[(id<ServiceImporter>)obj1 class] name] compare:[[(id<ServiceImporter>)obj2 class] name]];
		})];
		
		for (id<ServiceImporter> importer in importers) {
			NSMenuItem *item = [[NSMenuItem alloc] init];
			item.title = [[importer class] name];
			item.representedObject = importer;
			[[mManualTypeBtn menu] addItem:item];
		}
		
		mManualDidLoadTypes = TRUE;
	}
	
	[panel beginSheetModalForWindow:mParentWindow completionHandler:(^ (NSInteger result) {
		if (NSFileHandlingPanelOKButton == result) {
			NSArray *urls = [panel URLs];
			
			if ([urls count] != 0) {
				mLastImportUrl = [[urls objectAtIndex:0] URLByDeletingLastPathComponent];
				
				[mProgressSheetController setTitle:@"Importing chat logs. Please wait...."];
				[mProgressSheetController setSubtitle:@""];
				[mProgressSheetController setIndeterminateMode];
				[mProgressSheetController performSelectorOnMainThread:@selector(showInWindow:) withObject:mParentWindow waitUntilDone:FALSE];
				
				mImportFileName = nil;
				mImportDone = FALSE;
				
				mManualImporter = [[mManualTypeBtn selectedItem] representedObject];
				
				[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doActionImportUpdateProgress:) userInfo:nil repeats:TRUE];
				[NSThread detachNewThreadSelector:@selector(doActionImportThread:) toTarget:self withObject:urls];
			}
		}
	})];
}

/**
 *
 *
 */
- (void)importFile:(NSString *)filePath importer:(id<ServiceImporter>)importer
{
	ChatterObjectCache *cache = [ChatterObjectCache sharedInstance];
	
	//
	// search address book for a person for this account
	//
	void (^searchForPerson)(ChatterAccount*) = ^ (ChatterAccount *caccount) {
		ABSearchElementRef emailSearchRef = ABPersonCreateSearchElement((CFStringRef)kABEmailProperty, NULL, NULL, (__bridge CFTypeRef)(caccount.screenname), kABEqualCaseInsensitive);
		ABSearchElementRef imSearchRef = ABPersonCreateSearchElement((CFStringRef)kABInstantMessageProperty, NULL, NULL, (__bridge CFTypeRef)(caccount.screenname), kABEqualCaseInsensitive);
		NSArray *emailResults = (__bridge_transfer NSArray *)ABCopyArrayOfMatchingRecords((__bridge ABAddressBookRef)[ABAddressBook addressBook], emailSearchRef);
		NSArray *imResults = (__bridge_transfer NSArray *)ABCopyArrayOfMatchingRecords((__bridge ABAddressBookRef)[ABAddressBook addressBook], imSearchRef);
		ABPerson *person = nil;
		
		if ([imResults count] != 0)
			person = [imResults objectAtIndex:0];
		else if ([emailResults count] != 0)
			person = [emailResults objectAtIndex:0];
		else
			return;
		
		NSString *personUid = person.uniqueId;
		NSUInteger personId = [ChatterPerson dbobjectSelectIdByAddressBookUid:personUid];
		ChatterPerson *cperson;
		
		if (personId == 0) {
			NSData *imageData = person.imageData;
			NSImage *image = nil;
			
			if (imageData != nil)
				image = [[NSImage alloc] initWithData:imageData];
			
			cperson = [ChatterPerson person];
			cperson.firstName = [person valueForProperty:kABFirstNameProperty];
			cperson.lastName = [person valueForProperty:kABLastNameProperty];
			cperson.addressBookUid = personUid;
			[cperson dbobjectInsert];
			cperson.image = image;
			[cache addObject:cperson];
		}
		else
			cperson = [cache personForId:personId];
		
		caccount.person = cperson;
		
		CFRelease(emailSearchRef);
		CFRelease(imSearchRef);
	};
	
	//
	// handle an individual instant message within a chat session
	//
	BOOL (^importHandler)(NSMutableIndexSet*, ChatterSource*, ChatterSession*, ChatterMessage*) = ^ BOOL (NSMutableIndexSet *accountIds, ChatterSource *csource, ChatterSession *csession, ChatterMessage *cmessage) {
		ChatterAccount *caccount = nil;
		
		// skip the message if it lacks any of the required components
		if ([cmessage.timestampStr length] == 0 || [cmessage.screenname length] == 0 || [cmessage.message length] == 0)
			return FALSE;
		
		// skip the message if there's another message with the same timestamp, source, screenname and message.
		if (0 != ([ChatterMessage dbobjectSelectIdForTimestamp:cmessage.timestampStr sessionId:csession.databaseId screenName:cmessage.screenname message:cmessage.message]))
			return TRUE;
		
		if (cmessage.screenname != nil && nil == (caccount = [cache accountForName:cmessage.screenname])) {
			caccount = [ChatterAccount account];
			caccount.screenname = cmessage.screenname;
			searchForPerson(caccount);
			[caccount dbobjectInsert];
			[cache addObject:caccount];
		}
		
		[ChatterSessionAccount dbobjectInsertWithSession:csession andAccount:caccount];
		
		cmessage.session = csession;
		cmessage.source = csource;
		cmessage.account = caccount;
		
		if (TRUE == [cmessage dbobjectInsert])
			[cache addObject:cmessage];
		else
			NSLog(@"%s.. failed to insert message: %@", __PRETTY_FUNCTION__, cmessage);
		
		{
			NSArray *words = [Stemmer stemsForWords:cmessage.message];
			
			for (NSString *word in words) {
				if ([word length] != 0) {
					ChatterWord *cword = [cache wordForWord:word];
					
					if (cword == nil) {
						cword = [ChatterWord word];
						cword.word = word;
						[cword dbobjectInsert];
						[cache addObject:cword];
					}
					
					[ChatterMessageWord dbobjectInsertWithMessage:cmessage andWord:cword];
				}
			}
		}
		
		return TRUE;
	};
	
	//
	// handle a chat session (ie, a single chat log file)
	//
	void (^importFile)(NSString*, id<ServiceImporter>);
	
	importFile = ^ (NSString *filePath, id<ServiceImporter> importer) {
		NSUInteger mtime = 0;
		ChatterSource *csource = [cache sourceForPath:filePath];
		NSMutableIndexSet *accountIds = [NSMutableIndexSet indexSet];
		
		mImportFileName = [filePath lastPathComponent];
		
		if (csource != nil) {
			if ([csource.service isEqualToString:[[importer class] name]] && [csource.timestamp timeIntervalSince1970] == (mtime = [Easy mtimeForFilePath:filePath]))
				return;
			else {
				csource.service = [[importer class] name];
				csource.timestamp = [NSDate dateWithTimeIntervalSince1970:mtime];
				[csource dbobjectUpdate];
			}
		}
		else {
			csource = [ChatterSource source];
			csource.service = [[importer class] name];
			csource.filePath = filePath;
			csource.timestamp = [NSDate dateWithTimeIntervalSince1970:[Easy mtimeForFilePath:filePath]];
			[csource dbobjectInsert];
			[cache addObject:csource];
		}
		
		[[Easy dbconn] beginTransaction];
		[importer importFileAtPath:filePath withMessageClass:[ChatterMessage class] andHandler:(ServiceImporterMessageCallback)(^ (ChatterMessage *cmessage, BOOL *stop) {
			NSString *sessionName;
			ChatterSession *csession;
			
			if (nil == (sessionName = cmessage.sessionName))
				sessionName = filePath;
			
			if (nil == (csession = [cache sessionForName:sessionName])) {
				csession = [ChatterSession session];
				csession.source = csource;
				csession.name = sessionName;
				csession.timestamp = [NSDate dateWithTimeIntervalSince1970:[Easy mtimeForFilePath:filePath]];
				[csession dbobjectInsert];
				[cache addObject:csession];
			}
			
			importHandler(accountIds, csource, csession, cmessage);
		})];
		[[Easy dbconn] commitTransaction];
	};
	
	@autoreleasepool { importFile(filePath, importer); }
}

/**
 * Takes a list of URLs and processes them. Directories are interrogated fully. Files of supported
 * types are imported. Meanwhile, it also updates the import status so that the progress sheet
 * can show the user something interesting to watch.
 */
- (void)doActionImportThread:(NSArray *)urls
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSMutableDictionary *filesToImport = [NSMutableDictionary dictionary];
	id<ServiceImporter> defaultImporter = mManualImporter;
	
	mImportFilesTotal = 0;
	mImportFilesDone = 0;
	mImportScanning = TRUE;
	mImportImporting = FALSE;
	
	//
	// scan the selected files / directories and determine how many chat logs we're going to import.
	// if the user has specified a particular importer, then instead of automatically detecting the
	// appropriate importer, we will hand every file and directory to the user-specified importer.
	//
	for (NSURL *url in urls) {
		@autoreleasepool {
			BOOL isDir;
			NSString *targetPath = [url path];
			__block id<ServiceImporter> importer;
			
			if ([fileManager fileExistsAtPath:targetPath isDirectory:&isDir]) {
				mImportFileName = targetPath;
				
				if (defaultImporter) {
					[filesToImport setObject:defaultImporter forKey:targetPath];
					mImportFilesTotal += 1;
					
					if (isDir) {
						[Easy iterateDirectory:targetPath withHandle:(^ (NSString *filePath) {
							mImportFileName = filePath;
							[filesToImport setObject:defaultImporter forKey:filePath];
							mImportFilesTotal += 1;
						})];
					}
				}
				else if (nil != (importer = [ServiceImporter importerForFilePath:targetPath])) {
					[filesToImport setObject:importer forKey:targetPath];
					mImportFilesTotal += 1;
				}
				else if (isDir) {
					[Easy iterateDirectory:targetPath withHandle:(^ (NSString *filePath) {
						@autoreleasepool {
							if (nil != (importer = [ServiceImporter importerForFilePath:filePath])) {
								mImportFileName = filePath;
								[filesToImport setObject:importer forKey:filePath];
								mImportFilesTotal += 1;
							}
						}
					})];
				}
			}
		}
	}
	
	mImportFilesTotal = [filesToImport count];
	mImportImporting = TRUE;
	mImportScanning = FALSE;
	
	for (NSString *filePath in [filesToImport allKeys]) {
		@autoreleasepool {
			id<ServiceImporter> importer = [filesToImport objectForKey:filePath];
			
			mImportFilesDone += 1;
			[self importFile:filePath importer:importer];
			
			// this check stops an import after the message count reaches 10,000, but it's placement allows
			// a user to continue to import one file at a time thereafter.
#ifdef CHATTER_DEMO
			if ([cache messageCount] >= 10000)
				break;
#endif
		}
	}
	
	// clean up and cause the progress sheet to finish
	{
		mImportFileName = nil;
		mImportDone = TRUE;
	}
	
}

/**
 *
 *
 */
- (void)doActionImportUpdateProgress:(NSTimer *)timer
{
	NSString *fileName = mImportFileName;;
	
	if (mImportScanning) {
		if (fileName == nil)
			[mProgressSheetController setSubtitle:@"Scanning"];
		else
			[mProgressSheetController setSubtitle:[NSString stringWithFormat:@"Scanning '%@'", fileName]];
	}
	else if (mImportImporting && mImportFilesTotal && mImportFilesDone) {
		if (fileName == nil)
			[mProgressSheetController setSubtitle:@""];
		else {
			[mProgressSheetController setTitle:[NSString stringWithFormat:@"Importing chat logs. Please wait.... (%lu of %lu)", mImportFilesDone, mImportFilesTotal]];
			[mProgressSheetController setSubtitle:[NSString stringWithFormat:@"Importing '%@'", fileName]];
			[mProgressSheetController setPercent:((double)mImportFilesDone / (double)mImportFilesTotal)];
		}
	}
	else
		[mProgressSheetController setSubtitle:@""];
	
	
	if (mImportDone == TRUE) {
		[timer invalidate];
		[mProgressSheetController hide];
		[Easy postNotification:@"ChatterImportFinishedNotification" object:nil];
		return;
	}
}





#pragma mark - NSTableViewDataSource

/**
 *
 *
 */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	NSUInteger count = 0;
	
	@synchronized (mData) {
		count = [mData count];
	}
	
	return count;
}

/**
 *
 *
 */
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSNumber *number = nil;
	
	@synchronized (mData) {
		NSString *serviceName = [mData objectAtIndex:rowIndex];
		NSDictionary *serviceInfo = [mDataByService objectForKey:serviceName];
		
		number = [serviceInfo objectForKey:@"State"];
	}
	
	return number;
}





#pragma mark - NSTableViewDelegate

/**
 *
 *
 */
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	return FALSE;
}

/**
 *
 *
 */
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSString *serviceName;
	NSDictionary *serviceInfo;
	NSNumber *state=nil, *count=nil;
	NSButton *checkbox = [tableView makeViewWithIdentifier:@"SearchResult" owner:self];
	
	@synchronized (mData) {
		serviceName = [mData objectAtIndex:row];
		serviceInfo = [mDataByService objectForKey:serviceName];
		state = [serviceInfo objectForKey:@"State"];
		count = [serviceInfo objectForKey:@"Count"];
	}
	
	if (checkbox == nil) {
		checkbox = [[NSButton alloc] initWithFrame:NSMakeRect(0., 0., tableView.frame.size.width, 14.)];
		checkbox.identifier = @"SearchResult";
		checkbox.target = self;
		checkbox.action = @selector(doActionMagicalCheckboxToggled:);
		[checkbox setButtonType:NSSwitchButton];
	}
	
	[checkbox setTag:row];
	[checkbox setState:[state integerValue]];
	[checkbox setTitle:[NSString stringWithFormat:@"%@ %@ log files", count, serviceName]];
	
	
	return checkbox;
}

- (void)doActionMagicalCheckboxToggled:(NSButton *)button
{
	@synchronized (mData) {
		NSString *serviceName = [mData objectAtIndex:button.tag];
		NSMutableDictionary *serviceInfo = [mDataByService objectForKey:serviceName];
		
		[serviceInfo setObject:[NSNumber numberWithInteger:button.state] forKey:@"State"];
	}
}

@end
