//
//  ImportController.h
//  Chatter
//
//  Created by Jones Curtis on 2011.07.07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MetadataSearch;
@protocol ServiceImporter;
@class ProgressSheetController;

@interface ImportController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
{
@private
	NSWindow *mParentWindow;
	IBOutlet ProgressSheetController *mProgressSheetController;
	
	/* manual import */
	IBOutlet NSView *mManualAccessoryView;
	IBOutlet NSPopUpButton *mManualTypeBtn;
	NSOpenPanel *mManualOpenPanel;
	id<ServiceImporter> mManualImporter;
	BOOL mManualDidLoadTypes;
	
	/* magical import */
	IBOutlet NSWindow *mMagicalWindow;
	IBOutlet NSView *mMagicalView;
	IBOutlet NSTableView *mMagicalTableView;
	IBOutlet NSButton *mMagicalOkayBtn;
	IBOutlet NSButton *mMagicalCancelBtn;
	IBOutlet NSProgressIndicator *mMagicalPrg;
	
	/* state */
	NSURL *mLastImportUrl;
	NSURL *mLastExportUrl;
	NSString *mImportFileName;
	BOOL mImportDone;
	NSUInteger mImportFilesTotal;
	NSUInteger mImportFilesDone;
	BOOL mImportScanning;
	BOOL mImportImporting;
	
	/* magical data */
	BOOL mStop;
	NSMutableArray *mData;
	NSMutableDictionary *mDataByService;
}

/**
 * Magical import
 */
- (IBAction)doActionMagicalOkay:(id)sender;
- (IBAction)doActionMagicalCancel:(id)sender;

/**
 * Accessors
 */
- (void)showInWindow:(NSWindow *)window;

@end
