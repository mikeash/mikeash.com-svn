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
	return [[[self alloc] initWithUndoManager: undoManager logBook: logBook filter: filter] autorelease];
}

- (id)initWithUndoManager: (NSUndoManager *)undoManager logBook: (GBLogBook *)logBook filter: (GBFilter *)filter
{
	if( (self = [self init]) )
	{
		mUndoManager = [undoManager retain];
		mLogBook = [logBook retain];
		mEntries = [[filter filterArray: [logBook entries]] mutableCopy];
	}
	return self;
}

- (void)dealloc
{
	[mUndoManager release];
	[mLogBook release];
	[mEntries release];
	
	[super dealloc];
}

#pragma mark -

- (void)_noteDidChange
{
	[[NSNotificationCenter defaultCenter] postNotificationName: GBLogBookDidChangeNotification
														object: mLogBook];
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
	[self _noteDidChange];
}

- (void)makeNewEntry
{
	[[mUndoManager prepareWithInvocationTarget: self] _removeLastEntry];
	[mEntries addObject: [NSMutableDictionary dictionary]];
	[[mLogBook entries] addObject: [mEntries lastObject]];
	[self _noteDidChange];
}

- (id)_totalTimeForEntry: (int)entryIndex
{
	NSDictionary *dict = [mEntries objectAtIndex: entryIndex];
	NSString *timeKeys[] = { @"dual_time", @"pilot_in_command_time", @"solo_time", @"instruction_given_time", nil };
	
	int total = 0;
	
	NSString **key;
	for( key = timeKeys; *key; key++ )
		total += [[dict objectForKey: *key] intValue];
	
	return [NSNumber numberWithInt: total];
}

- (id)valueForEntry: (int)entryIndex identifier: (NSString *)identifier
{
	if( [identifier isEqualToString: @"number"] )
		return [NSNumber numberWithInt: [[mLogBook entries] indexOfObjectIdenticalTo: [mEntries objectAtIndex: entryIndex]] + 1];
	if( [identifier isEqualToString: @"total_time"] )
		return [self _totalTimeForEntry: entryIndex];
	
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
		
		[self _noteDidChange];
	}
}

- (int)totalForIdentifier: (NSString *)identifier
{
	int total = 0;
	forall( dict, mEntries )
	{
		id val = [dict objectForKey: identifier];
		total += [val intValue];
	}
	return total;
}

@end
