//
//  GBLogBookDocument.h
//  GlideBook
//
//  Created by Michael Ash on 4/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class GBDataView;
@class GBLogBook;

@interface GBLogBookDocument : NSDocument
{
	IBOutlet NSTableView*		mTableView;
	
	IBOutlet NSToolbarItem*		mSearchToolbarItem;
	IBOutlet NSToolbarItem*		mAddEntryToolbarItem;
	IBOutlet NSToolbarItem*		mRemoveEntryToolbarItem;
	IBOutlet NSSearchField*		mSearchField;
	
	GBLogBook*		mLogBook;
	GBDataView*		mDataView;
}

- (IBAction)addNewEntry: (id)sender;
- (IBAction)delete: (id)sender;

- (IBAction)filter: (id)sender;

- (void)setFilterPredicate: (NSPredicate *)predicate;

@end
