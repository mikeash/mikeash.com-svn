//
//  GBDataView.h
//  GlideBook
//
//  Created by Michael Ash on 5/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class GBLogBook;
@class GBFilter;

@interface GBDataView : NSObject
{
	NSUndoManager*		mUndoManager;
	GBLogBook*			mLogBook;
	NSMutableArray*		mEntries;
}

+ (id)dataViewWithUndoManager: (NSUndoManager *)undoManager logBook: (GBLogBook *)logBook filter: (GBFilter *)filter;

- (id)initWithUndoManager: (NSUndoManager *)undoManager logBook: (GBLogBook *)logBook filter: (GBFilter *)filter;

- (int)entriesCount;
- (void)makeNewEntry;
- (void)removeEntryAtIndex: (int)entryIndex;
- (int)logbookIndexForEntryIndex: (int)entryIndex;
- (int)entryIndexForLogbookIndex: (int)logbookIndex;
- (id)valueForEntry: (int)entryIndex identifier: (NSString *)identifier;
- (void)setValue: (id)value forEntry: (int)entryIndex identifier: (NSString *)identifier;
- (int)totalForIdentifier: (NSString *)identifier;
							
@end
