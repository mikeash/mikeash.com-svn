//
//  GBLogBook.h
//  GlideBook
//
//  Created by Michael Ash on 4/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


extern NSString * const GBLogBookDidChangeNotification;

@interface GBLogBook : NSObject
{
	NSUndoManager*		mUndoManager;
	NSMutableArray*		mEntries;
}

- (id)initWithUndoManager: (NSUndoManager *)undoManager;
- (id)initWithUndoManager: (NSUndoManager *)undoManager data: (NSData *)data error: (NSError **)outError;

- (NSData *)data;

- (int)entriesCount;
- (void)makeNewEntry;
- (id)valueForEntry: (int)entryIndex identifier: (NSString *)identifier;
- (void)setValue: (id)value forEntry: (int)entryIndex identifier: (NSString *)identifier;

@end
