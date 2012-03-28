//
//  ChatterAppDelegate.m
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterAppDelegate.h"
#import "DBConnection.h"
#import "SQLiteDBConnection.h"
#import "Easy.h"
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
#import "ProgressSheetController.h"
#import "ToolbarSearchItem.h"
#import "BuddyTableController.h"
#import "MessageTableController.h"
#import "ServiceImporter.h"
#import "PreferencesController.h"
#import "BuddyEditController.h"
#import "NSApplication+Additions.h"
#import "ConversationController.h"
#import "VersionChecker.h"
#import "ImportController.h"

@interface ChatterAppDelegate (PrivateMethods)
- (BOOL)initDatabase:(NSError **)error;
- (BOOL)initDatabaseCreate;
- (BOOL)initDatabaseConnect:(NSError **)error;
- (void)initDatabaseShowConversations;
- (BOOL)initDatabaseLoad;
- (void)disconnectFromDatabase;
- (void)doActionImportMagical;
- (void)doActionImportManual:(id)sender;
@end

@implementation ChatterAppDelegate

@synthesize window;
@synthesize dbConn = mDbConn;
@synthesize progressSheetController = mProgressSheetController;
@synthesize buddyEditController = mBuddyEditController;
@synthesize toolbar = mToolbar;





#pragma mark - NSApplicationDelegate

/**
 *
 *
 */
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	mIsTerminating = FALSE;
	mConversations = [[NSMutableDictionary alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doHandleImportFinishedNotification:) name:@"ChatterImportFinishedNotification" object:nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:TRUE], @"MainToolbarVisible", nil]];
	[[NSProcessInfo processInfo] disableSuddenTermination];
	
	//[Easy postNotification:@"ChatterNotificationStatusTextChanged" object:@"0 buddies, 0 chats, 0 messages, 0 distinct words"];
	
	// initialize the database
	{
		NSError *error = nil;
		
		if (FALSE == [self initDatabase:&error]) {
			NSAlert *alert = [NSAlert alertWithMessageText:@"An error occurred while initializing the database. There's nothing more I can do. I hope the rest of your day goes better. Sorry. Bye." 
																			 defaultButton:@"Quit" alternateButton:@"" otherButton:@"" informativeTextWithFormat:[error localizedDescription]];
			[alert setAlertStyle:NSCriticalAlertStyle];
			[alert runModal];
			[[NSApplication sharedApplication] terminate:nil];
		}
	}
	
	// reset all of the counts for the toolbar stats and start the timer for updating the status bar
	{
		mLastAccountCount = 0;
		mLastMessageCount = 0;
		mLastPersonCount = 0;
		mLastSourceCount = 0;
		mLastWordCount = 0;
		
		[NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(doActionStatusbarUpdate:) userInfo:nil repeats:TRUE];
	}
	
	[ServiceImporter loadImporters];
}

/**
 *
 *
 */
- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self disconnectFromDatabase];
	
	// TODO: wait for threads to stop
	
//[NSApp replyToApplicationShouldTerminate:TRUE]
}

/**
 *
 *
 */
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	mIsTerminating = TRUE;
	
	// NSTerminateLater
	// NSTerminateNow
	// NSTerminateCancel
	
	return NSTerminateNow;
}




#pragma mark - Database

/**
 * Copy the default database if it doesn't exist. Connect to the database.
 *
 */
- (BOOL)initDatabaseCreate
{
	NSError *error;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSString *dstDir = [[Easy pathToApplicationSupportDirectory] stringByAppendingPathComponent:@"Chatter"];
	NSString *dbSrcPath = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"db"];
	NSString *dbDstPath = [dstDir stringByAppendingPathComponent:@"default.db"];
	
	// the database already exists; we're done here
	if (TRUE == [fileManager fileExistsAtPath:dbDstPath])
		return TRUE;
	
	// attempt to create the application support directory for this program
	if (FALSE == [fileManager fileExistsAtPath:dstDir]) {
		if (FALSE == [fileManager createDirectoryAtPath:dstDir withIntermediateDirectories:TRUE attributes:nil error:&error]) {
			NSLog(@"%s.. failed to create application support directory at, '%@' because, %@", __PRETTY_FUNCTION__, dstDir, [error localizedDescription]);
			return FALSE;
		}
	}
	
	// copy the default database from the application bundle to the application support directory
	if (FALSE == [fileManager copyItemAtPath:dbSrcPath toPath:dbDstPath error:&error]) {
		NSLog(@"%s.. failed to copy '%@' to '%@' because %@", __PRETTY_FUNCTION__, dbSrcPath, dbDstPath, [error localizedDescription]);
		return FALSE;
	}
	
	return TRUE;
}

/**
 * Try to connect to an existing database.
 *
 */
- (BOOL)initDatabaseConnect:(NSError **)error
{
	DBConnection *dbconn = nil;
	NSString *dbPath = [[Easy pathToApplicationSupportDirectory] stringByAppendingPathComponent:@"Chatter/default.db"];
	
	// fail if the document is already connected to a database
	if (mDbConn != nil)
		return TRUE;
	
	// create a new database connection object
	dbconn = [[SQLiteDBConnection alloc] initWithFileName:dbPath];
	
	// update the database schema if it is out-of-date
	if (FALSE == [dbconn verify:error]) {
		NSLog(@"%s.. failed to verify the database", __PRETTY_FUNCTION__);
		return FALSE;
	}
	
	// attempt to connect to the database
	if (FALSE == [dbconn connect]) {
		NSLog(@"%s.. failed to connect", __PRETTY_FUNCTION__);
		return FALSE;
	}
	
	// keep a handle on the database connection; we'll probably need it later
	mDbConn = dbconn;
	[Easy setDbConn:dbconn];
	
	// tell the peepz that everything is good
	NSLog(@"%s.. connected to database, '%@'", __PRETTY_FUNCTION__, dbPath);
	
	// yee-ha
	return TRUE;
}

/**
 * Load all of the data from the database into the object cache.
 *
 */
- (BOOL)initDatabaseLoad
{
	[mProgressSheetController setTitle:@"Loading the database. Please wait...."];
	[mProgressSheetController setSubtitle:@""];
	[mProgressSheetController showInWindow:window];
	
	mDatabaseLoadType = nil;
	mDatabaseLoadCount = 0;
	mDatabaseTotalCount = 0;
	mDatabaseLoadDone = FALSE;
	
	[mProgressSheetController setSubtitle:@"Loading"];
	[mProgressSheetController setPercent:0.];
	
	[NSThread detachNewThreadSelector:@selector(initDatabaseLoadThread) toTarget:self withObject:nil];
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(initDatabaseLoadUpdateProgress:) userInfo:nil repeats:TRUE];
	
	return TRUE;
}

/**
 * The thread that actually loads the database, which could be a lengthy process and during which
 * process we wouldn't want to block the main thread.
 */
- (void)initDatabaseLoadThread
{
	@autoreleasepool {
		ChatterObjectCache *objectCache = [ChatterObjectCache sharedInstance];
		
		BOOL (^handler)(ChatterObject*) = ^ BOOL (ChatterObject *cobject) {
			[objectCache addObject:cobject];
			mDatabaseLoadCount += 1;
			return TRUE;
		};
		
		// object count
		mDatabaseTotalCount += [ChatterAccount dbobjectSelectCount];
		mDatabaseTotalCount += [ChatterMessage dbobjectSelectCount];
		mDatabaseTotalCount += [ChatterPerson dbobjectSelectCount];
		mDatabaseTotalCount += [ChatterSession dbobjectSelectCount];
		mDatabaseTotalCount += [ChatterSetting dbobjectSelectCount];
		mDatabaseTotalCount += [ChatterSource dbobjectSelectCount];
		mDatabaseTotalCount += [ChatterWord dbobjectSelectCount];
		
		// accounts
		mDatabaseLoadType = @"accounts";
		[ChatterAccount dbobjectSelectAllWithHandler:(BOOL (^)(ChatterAccount*))handler];
		
		// persons
		mDatabaseLoadType = @"persons";
		[ChatterPerson dbobjectSelectAllWithHandler:(BOOL (^)(ChatterPerson*))handler];
		
		// sessions
		mDatabaseLoadType = @"sessions";
		[ChatterSession dbobjectSelectAllWithHandler:(BOOL (^)(ChatterSession*))handler];
		
		// settings
		mDatabaseLoadType = @"settings";
		[ChatterSetting dbobjectSelectAllWithHandler:(BOOL (^)(ChatterSetting*))handler];
		
		// sources
		mDatabaseLoadType = @"sources";
		[ChatterSource dbobjectSelectAllWithHandler:(BOOL (^)(ChatterSource*))handler];
		
		// words
		mDatabaseLoadType = @"words";
		[ChatterWord dbobjectSelectAllWithHandler:(BOOL (^)(ChatterWord*))handler];
		
		// messages
		mDatabaseLoadType = @"messages";
		[ChatterMessage dbobjectSelectAllWithHandler:(BOOL (^)(ChatterMessage*))handler];
		
		mDatabaseLoadDone = TRUE;
		mDatabaseLoadType = nil;
		
		[self performSelectorOnMainThread:@selector(initDatabaseShowConversations) withObject:nil waitUntilDone:FALSE];
	
	}
}

/**
 * Re-open all of the conversation windows that were left open when we last quit.
 *
 */
- (void)initDatabaseShowConversations
{
	NSMutableArray *csettings = [[NSMutableArray alloc] init];
	ChatterObjectCache *cache = [ChatterObjectCache sharedInstance];
	
	[ChatterSetting dbobjectSelectAllForName:@"Conversation" withHandler:(^ BOOL (ChatterSetting *csetting) {
		[csettings addObject:csetting];
		return TRUE;
	})];
	
	for (ChatterSetting *csetting in csettings) {
		[self doActionShowConversation:[cache sessionForName:csetting.valueString] showMessage:nil];
		
		/*
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		if (FALSE == [fileManager fileExistsAtPath:filePath])
			[ChatterSetting dbobjectDeleteForName:@"Conversation" andValue:filePath];
		else if (nil == (csession = [cache sourceForPath:filePath]))
			[ChatterSetting dbobjectDeleteForName:@"Conversation" andValue:filePath];
		else
			[self doActionShowConversation:csession showMessage:nil];
		*/
	}
	
}

/**
 *
 *
 */
- (void)initDatabaseLoadUpdateProgress:(NSTimer *)timer
{
	if (mDatabaseLoadDone == TRUE) {
		[timer invalidate];
		[mProgressSheetController hide];
		[NSThread detachNewThreadSelector:@selector(loadData) toTarget:mMessageTableController withObject:nil];
		[NSThread detachNewThreadSelector:@selector(loadData) toTarget:mBuddyTableController withObject:nil];
		
		if ([[ChatterObjectCache sharedInstance] messageCount] == 0)
			[mImportController showInWindow:self.window];
		
		return;
	}
	
	NSString *type = mDatabaseLoadType;
	
	if (type == nil)
		[mProgressSheetController setSubtitle:[NSString stringWithFormat:@"Loading", mDatabaseLoadCount]];
	else if (mDatabaseLoadCount && mDatabaseTotalCount) {
		[mProgressSheetController setPercent:((double)mDatabaseLoadCount / (double)mDatabaseTotalCount)];
		[mProgressSheetController setSubtitle:[NSString stringWithFormat:@"Loading %@", type]];
	}
}

/**
 * Create it if it doesn't exist. Connect to it afterwards.
 *
 */
- (BOOL)initDatabase:(NSError **)error
{
	if (FALSE == [self initDatabaseCreate]) {
		NSLog(@"%s.. failed to initDatabaseCreate()", __PRETTY_FUNCTION__);
		return FALSE;
	}
	
	if (FALSE == [self initDatabaseConnect:error]) {
		NSLog(@"%s.. failed to initDatabaseConnect()", __PRETTY_FUNCTION__);
		return FALSE;
	}
	
	if (FALSE == [self initDatabaseLoad]) {
		NSLog(@"%s.. failed to initDatabaseLoad()", __PRETTY_FUNCTION__);
		return FALSE;
	}
	
	return TRUE;
}

/**
 *
 *
 */
- (void)disconnectFromDatabase
{
	[Easy setDbConn:nil];
	
	// if we're not connected to the database then we're already done
	if (mDbConn == nil)
		return;
	
	// attempt to disconnect from the database
	if (FALSE == [mDbConn disconnect]) {
		NSLog(@"%s.. failed to disconnect. why?", __PRETTY_FUNCTION__);
		return;
	}
	
	// clear out the database connection object
	mDbConn = nil;
}






#pragma mark - Callbacks

/**
 *
 *
 */
- (IBAction)doActionPreferences:(id)sender
{
	[mPreferencesController showInWindow:self.window];
}

/**
 *
 *
 */
- (IBAction)doActionFeedback:(id)sender
{
	NSMutableString *url = [NSMutableString string];
	NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
	NSString *chatterVersion = [appInfo objectForKey:@"CFBundleShortVersionString"];
	NSString *chatterBuild = [appInfo objectForKey:(NSString *)kCFBundleVersionKey];
	
	[url appendString:@"mailto:curtis.jones@gmail.com?"];
	[url appendString:@"subject=Chatter%20Feedback&"];
	[url appendString:@"body=Curtis,%0A%0AChatter%20is%20the%20best%20program%20ever.%20I%20just%20wanted%20to%20let%20you%20know%20that.%20Also,%20..."];
	[url appendString:@"%0A%0A--%0A%0A"];
	[url appendFormat:@"Chatter%%20v%@%%20(%@)%%0A", chatterVersion, chatterBuild];
	[url appendFormat:@"Mac%%20OS%%20X%%20v%@%%0A", [NSApp systemVersionString]];
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];	
}

/**
 *
 *
 */
- (IBAction)doActionUpdate:(id)sender
{
	NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
	NSString *ourVersion = [appInfo objectForKey:@"CFBundleShortVersionString"];
	NSUInteger ourBuild = [[appInfo objectForKey:(NSString *)kCFBundleVersionKey] integerValue];
	
	[[VersionChecker sharedInstance] checkWithHandler:(^ (NSString *version, NSUInteger build, NSError *error) {
		if (error) {
			NSAlert *alert = [NSAlert alertWithMessageText:@"An error occurred while checking for updates. Please try again later." defaultButton:@"Okay" alternateButton:@"" otherButton:@"" informativeTextWithFormat:[error localizedDescription]];
			[alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
		}
		else if (build > ourBuild) {
			NSAlert *alert = [NSAlert alertWithMessageText:@"Congratulations! A newer version of Chatter is now available." defaultButton:@"Upgrade" alternateButton:@"Cancel" otherButton:@"" informativeTextWithFormat:[NSString stringWithFormat:@"The latest version is %@ (%lu) and you are using %@ (%lu).", version, build, ourVersion, ourBuild]];
			[alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(doActionUpdateSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
		}
		else {
			NSAlert *alert = [NSAlert alertWithMessageText:@"You are using the latest version of Chatter. No updates are available at this time." defaultButton:@"Okay" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@"Have a nice day."];
			[alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
		}
	})];
}

/**
 *
 *
 */
- (void)doActionUpdateSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
	[[alert window] orderOut:self];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://curtisjones.us/chatter"]];	
}




#pragma mark - Import

/**
 *
 *
 */
- (IBAction)doActionImport:(id)sender
{
	[mImportController showInWindow:self.window];
}

/**
 *
 *
 */
- (void)doHandleImportFinishedNotification:(NSNotification *)notification
{
	[NSThread detachNewThreadSelector:@selector(loadData) toTarget:mMessageTableController withObject:nil];
	[NSThread detachNewThreadSelector:@selector(loadData) toTarget:mBuddyTableController withObject:nil];
}

/**
 *
 *
 */
- (IBAction)doActionExport:(id)sender
{
	
}

/**
 *
 *
 */
- (void)doActionStatusbarUpdate:(NSTimer *)timer
{
	ChatterObjectCache *cache = [ChatterObjectCache sharedInstance];
	NSUInteger accountCount, messageCount, personCount, sourceCount, wordCount;
	
	accountCount = [cache accountCount];
	messageCount = [cache messageCount];
	personCount = [cache personCount];
	sourceCount = [cache sourceCount];
	wordCount = [cache wordCount];
	
	if (accountCount != mLastAccountCount ||
			messageCount != mLastMessageCount ||
			personCount != mLastPersonCount ||
			sourceCount != mLastSourceCount ||
			wordCount != mLastWordCount) {
		[Easy postNotification:@"ChatterNotificationStatusTextChanged" object:[NSString stringWithFormat:@"%u people, %u buddies, %u chats, %u messages, %u distinct words",
																																					 personCount, accountCount, sourceCount, messageCount, wordCount]];
		
		[mPersonAccountSeg setLabel:[NSString stringWithFormat:@"People (%lu)", personCount] forSegment:0];
		[mPersonAccountSeg setLabel:[NSString stringWithFormat:@"Accounts (%lu)", accountCount] forSegment:1];
		
		mLastAccountCount = accountCount;
		mLastMessageCount = messageCount;
		mLastPersonCount = personCount;
		mLastSourceCount = sourceCount;
		mLastWordCount = wordCount;
	}
}





#pragma mark - Conversations

/**
 *
 *
 */
- (void)doActionShowConversation:(ChatterSession *)csession showMessage:(ChatterMessage *)cmessage
{
	@autoreleasepool {
		ConversationController *conversation = [mConversations objectForKey:csession];
		ChatterObjectCache *cache = [ChatterObjectCache sharedInstance];
		
		if (conversation == nil) {
			NSMutableArray *messages = [NSMutableArray array];
			NSMutableIndexSet *messageIds = [NSMutableIndexSet indexSet];
			
			[ChatterMessage dbobjectSelectIDsForSessionId:csession.databaseId withHandler:(^ BOOL (NSUInteger messageId) {
				[messageIds addIndex:messageId];
				return TRUE;
			})];
			
			[messageIds enumerateIndexesUsingBlock:(^ (NSUInteger messageId, BOOL *stop) {
				[messages addObject:[cache messageForId:messageId]];
			})];
			
			conversation = [[ConversationController alloc] initWithMessages:messages];
			conversation.session = csession;
			
			[ChatterSetting dbobjectInsertSettingWithName:@"Conversation" andValue:csession.name];
			
			[mConversations setObject:conversation forKey:csession];
		}
		
		[conversation show:cmessage];
	}
}

/**
 *
 *
 */
- (void)doActionRemoveConversation:(ConversationController *)conversation
{
	if (!mIsTerminating) {
		[ChatterSetting dbobjectDeleteForName:@"Conversation" andValue:conversation.session.name];
		[mConversations removeObjectForKey:conversation.session];
	}
}





#pragma mark - Toolbar

/**
 *
 *
 */
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:@"ChatterImportItemIdentifier",
																	 @"ChatterExportItemIdentifier",
																	 @"ChatterStatsItemIdentifier",
																	 @"ChatterFeedbackItemIdentifier",
																	 @"ChatterUpdateItemIdentifier",
																	 @"ChatterPrefsItemIdentifier",
																	 NSToolbarFlexibleSpaceItemIdentifier,
																	 NSToolbarSpaceItemIdentifier,
																	 @"ChatterSearch", nil];
	
}

/**
 *
 *
 */
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:@"ChatterImportItemIdentifier",
																	 @"ChatterExportItemIdentifier",
																	 NSToolbarFlexibleSpaceItemIdentifier,
																	 @"ChatterStatsItemIdentifier",
																	 @"ChatterFeedbackItemIdentifier",
																	 @"ChatterUpdateItemIdentifier",
																	 @"ChatterPrefsItemIdentifier",
																	 NSToolbarFlexibleSpaceItemIdentifier,
																	 NSToolbarSpaceItemIdentifier,
																	 @"ChatterSearch", nil];
}

/**
 *
 *
 */
- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)str willBeInsertedIntoToolbar:(BOOL)flag
{
	if ([str isEqualToString:@"ChatterSearch"]) {
		ToolbarSearchItem *searchItem = [[ToolbarSearchItem alloc] initWithItemIdentifier:@"ChatterSearch"];
		
		[searchItem setLabel:@"Search"];
		[searchItem setPaletteLabel:@"Search"];
		
		return searchItem;
	}
	else if ([str isEqualToString:@"ChatterImportItemIdentifier"]) {
		NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:str];
		
		[toolbarItem setLabel:@"Import"];
		[toolbarItem setPaletteLabel:@"Import"];
		
		[toolbarItem setToolTip:@"Import chat logs"];
		[toolbarItem setImage: [NSImage imageNamed:@"import-icon"]];
		
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(doActionImport:)];
		
		return toolbarItem;
	}
	else if ([str isEqualToString:@"ChatterExportItemIdentifier"]) {
		NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:str];
		
		[toolbarItem setLabel:@"Export"];
		[toolbarItem setPaletteLabel:@"Export"];
		
		[toolbarItem setToolTip:@"Export chat logs"];
		[toolbarItem setImage: [NSImage imageNamed:@"export-icon"]];
		
		return toolbarItem;
	}
	else if ([str isEqualToString:@"ChatterStatsItemIdentifier"]) {
		NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:str];
		
		[toolbarItem setLabel:@"Statistics"];
		[toolbarItem setPaletteLabel:@"Statistics"];
		
		[toolbarItem setToolTip:@"Chat statistics"];
		[toolbarItem setImage: [NSImage imageNamed:@"stats-icon"]];
		
		return toolbarItem;
	}
	else if ([str isEqualToString:@"ChatterFeedbackItemIdentifier"]) {
		NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:str];
		
		[toolbarItem setLabel:@"Feedback"];
		[toolbarItem setPaletteLabel:@"Feedback"];
		
		[toolbarItem setToolTip:@"Send feedback, comments, bug reports, feature requests."];
		[toolbarItem setImage: [NSImage imageNamed:@"feedback-icon"]];
		
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(doActionFeedback:)];
		
		return toolbarItem;
	}
	else if ([str isEqualToString:@"ChatterUpdateItemIdentifier"]) {
		NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:str];
		
		[toolbarItem setLabel:@"Update"];
		[toolbarItem setPaletteLabel:@"Update"];
		
		[toolbarItem setToolTip:@"Check for updates."];
		[toolbarItem setImage: [NSImage imageNamed:@"update-icon"]];
		
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(doActionUpdate:)];
		
		return toolbarItem;
	}
	else if ([str isEqualToString:@"ChatterPrefsItemIdentifier"]) {
		NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:str];
		
		[toolbarItem setLabel:@"Preferences"];
		[toolbarItem setPaletteLabel:@"Preferences"];
		
		[toolbarItem setToolTip:@"Preferences"];
		[toolbarItem setImage: [NSImage imageNamed:@"prefs-icon"]];
		
//	[toolbarItem setTarget:self];
//	[toolbarItem setAction:@selector(doActionPreferences:)];
		
		return toolbarItem;
	}
	else {
		NSLog(@"%s.. identifier = %@", __PRETTY_FUNCTION__, str);
		return nil;
	}
}





#pragma mark - Helpers

/**
 *
 *
 */
+ (ChatterAppDelegate *)appDelegate
{
	return (ChatterAppDelegate *)[[NSApplication sharedApplication] delegate];
}

@end
