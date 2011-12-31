//
//  ChatterAppDelegate.h
//  Chatter
//
//  Created by Curtis Jones on 2011.06.21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DBConnection;
@class ProgressSheetController;
@class BuddyTableController;
@class MessageTableController;
@class PreferencesController;
@class BuddyEditController;
@class ChatterMessage;
@class ChatterSession;
@class ConversationController;
@class ImportController;

@interface ChatterAppDelegate : NSObject <NSApplicationDelegate, NSToolbarDelegate, NSSplitViewDelegate, NSOpenSavePanelDelegate> {
@private
	/* application */
	BOOL mIsTerminating;
	
	/* interface - main */
	NSWindow *window;
	ProgressSheetController *mProgressSheetController;
	IBOutlet PreferencesController *mPreferencesController;
	IBOutlet ImportController *mImportController;
	
	/* interface - messages */
	IBOutlet NSTableView *mMessageTbl;
	IBOutlet MessageTableController *mMessageTableController;
	
	/* interface - buddy/person list */
	IBOutlet NSTableView *mBuddyTbl;
	IBOutlet BuddyTableController *mBuddyTableController;
	IBOutlet BuddyEditController *mBuddyEditController;
	IBOutlet NSSegmentedControl *mPersonAccountSeg;
	
	/* database loading */
	NSString *mDatabaseLoadType;
	NSUInteger mDatabaseLoadCount;
	NSUInteger mDatabaseTotalCount;
	BOOL mDatabaseLoadDone;
	
	/* toolbar */
	NSToolbar *mToolbar;
	IBOutlet NSToolbarItem *mImportToolbarItem;
	IBOutlet NSToolbarItem *mExportToolbarItem;
	
	/* statusbar */
	NSUInteger mLastAccountCount;
	NSUInteger mLastMessageCount;
	NSUInteger mLastPersonCount;
	NSUInteger mLastSourceCount;
	NSUInteger mLastWordCount;
	
	/* conversations */
	NSMutableDictionary *mConversations;
	
@private
	DBConnection *mDbConn;
}

@property (readwrite, assign) IBOutlet ProgressSheetController *progressSheetController;
@property (readwrite, assign) IBOutlet BuddyEditController *buddyEditController;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSToolbar *toolbar;
@property (readonly) DBConnection *dbConn;

+ (ChatterAppDelegate *)appDelegate;
- (void)doActionShowConversation:(ChatterSession *)session showMessage:(ChatterMessage *)cmessage;
- (void)doActionRemoveConversation:(ConversationController *)conversation;

@end
