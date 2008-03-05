//
//  GBDataView.m
//  GlideBook
//
//  Created by Michael Ash on 5/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GBDataView.h"

#import "GBFilter.h"
#import "GBLogBook.h"


@implementation GBDataView

+ (id)dataViewWithUndoManager: (NSUndoManager *)undoManager logBook: (GBLogBook *)logBook filter: (GBFilter *)filter
{
	return [[self alloc] initWithUndoManager: undoManager logBook: logBook filter: filter];
}

- (id)initWithUndoManager: (NSUndoManager *)undoManager logBook: (GBLogBook *)logBook filter: (GBFilter *)filter
{
	if( (self = [self init]) )
	{
		mUndoManager = undoManager;
		mLogBook = logBook;
		mEntries = [[filter filterArray: [logBook entries]] mutableCopy];
	}
	return self;
}

#pragma mark -

- (void)_noteDidChangeAtIndex: (int)entryIndex
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSIndexSet indexSetWithIndex: [self logbookIndexForEntryIndex: entryIndex]], @"indexes",
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName: GBLogBookDidChangeNotification
														object: mLogBook
													  userInfo: userInfo];
}

- (int)entriesCount
{
	return [mEntries count];
}

- (void)_removeLastEntry
{
	[[mUndoManager prepareWithInvocationTarget: self] makeNewEntry];
	[[mLogBook entries] removeObjectIdenticalTo: [mEntries lastObject]];
	[mEntries removeLastObject];
	[self _noteDidChangeAtIndex: [mEntries count] - 1];
}

- (void)makeNewEntry
{
	[[mUndoManager prepareWithInvocationTarget: self] _removeLastEntry];
	[mEntries addObject: [NSMutableDictionary dictionary]];
	[[mLogBook entries] addObject: [mEntries lastObject]];
	[self _noteDidChangeAtIndex: [mEntries count] - 1];
}

- (void)_addEntry: (NSMutableDictionary *)entry atIndex: (int)entryIndex logbookIndex: (int)logbookIndex
{
	[[mUndoManager prepareWithInvocationTarget: self] removeEntryAtIndex: entryIndex];
	
	[mEntries insertObject: entry atIndex: entryIndex];
	[[mLogBook entries] insertObject: entry atIndex: logbookIndex];
	[self _noteDidChangeAtIndex: entryIndex];
}

- (void)removeEntryAtIndex: (int)entryIndex
{
	NSMutableDictionary *entry = [mEntries objectAtIndex: entryIndex];
	int logbookIndex = [self logbookIndexForEntryIndex: entryIndex];
	[[mUndoManager prepareWithInvocationTarget: self] _addEntry: entry atIndex: entryIndex logbookIndex: logbookIndex];
	
	[mEntries removeObjectAtIndex: entryIndex];
	[[mLogBook entries] removeObjectAtIndex: logbookIndex];
	[self _noteDidChangeAtIndex: entryIndex];
}

- (int)logbookIndexForEntryIndex: (int)entryIndex
{
	return [[mLogBook entries] indexOfObjectIdenticalTo: [mEntries objectAtIndex: entryIndex]];
}

- (int)entryIndexForLogbookIndex: (int)logbookIndex
{
	return [mEntries indexOfObjectIdenticalTo: [[mLogBook entries] objectAtIndex: logbookIndex]];
}

- (int)_totalTimeForEntry: (int)entryIndex
{
	NSDictionary *dict = [mEntries objectAtIndex: entryIndex];
	NSString *timeKeys[] = { @"dual_time", @"pilot_in_command_time", @"solo_time", @"instruction_given_time", nil };
	
	int total = 0;
	
	NSString **key;
	for( key = timeKeys; *key; key++ )
		total += [[dict objectForKey: *key] intValue];
	
	return total;
}

- (id)valueForEntry: (int)entryIndex identifier: (NSString *)identifier
{
	if( [identifier isEqualToString: @"number"] )
		return [NSNumber numberWithInt: [[mLogBook entries] indexOfObjectIdenticalTo: [mEntries objectAtIndex: entryIndex]] + 1];
	if( [identifier isEqualToString: @"total_time"] )
		return [NSNumber numberWithInt: [self _totalTimeForEntry: entryIndex]];
	
	return [[mEntries objectAtIndex: entryIndex] objectForKey: identifier];
}

- (void)setValue: (id)value forEntry: (int)entryIndex identifier: (NSString *)identifier
{
	if( !identifier )
		return;
	
	id oldValue = [self valueForEntry: entryIndex identifier: identifier];
	if( ![oldValue isEqual: value] )
	{
		[[mUndoManager prepareWithInvocationTarget: self] setValue: oldValue
														  forEntry: entryIndex
														identifier: identifier];
		[[mEntries objectAtIndex: entryIndex] setValue: value forKey: identifier];
		
		[self _noteDidChangeAtIndex: entryIndex];
	}
}

- (int)totalForIdentifier: (NSString *)identifier
{
	BOOL isTotalTime = [identifier isEqualToString: @"total_item"];
	int total = 0;
	int count = [self entriesCount];
	int i;
	for( i = 0; i < count; i++ )
		total += (isTotalTime
				  ? [self _totalTimeForEntry: i]
				  : [[self valueForEntry: i identifier: identifier] intValue]);
	return total;
}

@end
