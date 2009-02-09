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


static int TotalTimeForEntry( NSDictionary *entry )
{
	NSString *timeKeys[] = { @"dual_time", @"pilot_in_command_time", @"solo_time", @"instruction_given_time", nil };
	
	int total = 0;
	
	NSString **key;
	for( key = timeKeys; *key; key++ )
		total += [[entry objectForKey: *key] intValue];
	
	return total;
}

static id ValueForEntry( NSDictionary *entry, NSString *key, GBLogBook *logBook )
{
	if( [key isEqualToString: @"number"] )
		return [NSNumber numberWithInt: [[logBook entries] indexOfObjectIdenticalTo: entry] + 1];
	if( [key isEqualToString: @"total_time"] )
		return [NSNumber numberWithInt: TotalTimeForEntry( entry )];
	
	return [entry objectForKey: key];
}	

@interface GBDataViewDictionaryProxy : NSObject
{
	GBLogBook *_logBook;
	NSDictionary *_origDict;
}

+ (id)proxyWithLogBook: (GBLogBook *)logBook originalDictionary: (NSDictionary *)dict;
- (id)initWithLogBook: (GBLogBook *)logBook originalDictionary: (NSDictionary *)dict;

- (NSDictionary *)originalDictionary;

@end

@implementation GBDataViewDictionaryProxy

static NSDictionary *kKeyMap;

+ (void)initialize
{
	if( !kKeyMap )
	{
		kKeyMap = [NSDictionary dictionaryWithObjectsAndKeys:
				   @"_dateMap:", @"date",
				   @"_checkedMap:", @"aerotow",
				   @"_checkedMap:", @"winch",
				   @"_numberMap:", @"dual_time",
				   @"_numberMap:", @"pilot_in_command_time",
				   @"_numberMap:", @"solo_time",
				   @"_numberMap:", @"instruction_given_time",
				   @"_numberMap:", @"total_time",
				   nil];
	}
}

+ (id)proxyWithLogBook: (GBLogBook *)logBook originalDictionary: (NSDictionary *)dict
{
	return [[self alloc] initWithLogBook: logBook originalDictionary: dict];
}

- (id)initWithLogBook: (GBLogBook *)logBook originalDictionary: (NSDictionary *)dict
{
	if( (self = [self init]) )
	{
		_logBook = logBook;
		_origDict = dict;
	}
	return self;
}

- (id)_dateMap: (id)obj
{
	return [NSCalendarDate dateWithString: obj calendarFormat: @"%m/%d/%y"];
}

- (id)_checkedMap: (id)obj
{
	return [obj boolValue] ? @"checked" : @"unchecked";
}

- (id)_numberMap: (id)obj
{
	return [NSNumber numberWithInt: [obj intValue]];
}

- (id)valueForKey: (NSString *)key
{
	id val = ValueForEntry( _origDict, key, _logBook );
	
	NSString *selStr = [kKeyMap objectForKey: key];
	if( selStr )
		val = [self performSelector: NSSelectorFromString( selStr ) withObject: val];
	
	return val;
}

- (NSDictionary *)originalDictionary
{
	return _origDict;
}

@end


@implementation GBDataView

+ (id)dataViewWithUndoManager: (NSUndoManager *)undoManager logBook: (GBLogBook *)logBook predicate: (NSPredicate *)predicate
{
	return [[self alloc] initWithUndoManager: undoManager logBook: logBook predicate: predicate];
}

- (id)initWithUndoManager: (NSUndoManager *)undoManager logBook: (GBLogBook *)logBook predicate: (NSPredicate *)predicate
{
	if( (self = [self init]) )
	{
		mUndoManager = undoManager;
		mLogBook = logBook;
		
		NSMutableArray *array = [NSMutableArray array];
		for( NSDictionary *item in [logBook entries] )
			[array addObject: [GBDataViewDictionaryProxy proxyWithLogBook: logBook originalDictionary: item]];
		NSArray *filtered = [array filteredArrayUsingPredicate: predicate];
		[array removeAllObjects];
		for( id item in filtered )
			[array addObject: [item originalDictionary]];
		mEntries = array;
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

- (id)valueForEntry: (int)entryIndex identifier: (NSString *)identifier
{
	NSDictionary *entry = [mEntries objectAtIndex: entryIndex];
	return ValueForEntry( entry, identifier, mLogBook );
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
				  ? TotalTimeForEntry( [mEntries objectAtIndex: i] )
				  : [[self valueForEntry: i identifier: identifier] intValue]);
	return total;
}

@end
