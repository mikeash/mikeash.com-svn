//
//  GBLogBook.m
//  GlideBook
//
//  Created by Michael Ash on 4/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GBLogBook.h"


NSString * const GBLogBookDidChangeNotification = @"GBLogBookDidChangeNotification";

@implementation GBLogBook

- (id)initWithUndoManager: (NSUndoManager *)undoManager;
{
	if( (self = [self init]) )
	{
		mUndoManager = undoManager;
		mEntries = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithUndoManager: (NSUndoManager *)undoManager data: (NSData *)data error: (NSError **)outError
{
	if( (self = [self initWithUndoManager: undoManager]) )
	{
		NSString *errorString = nil;
		
		[mEntries release];
		mEntries = [[NSPropertyListSerialization propertyListFromData: data
													 mutabilityOption: NSPropertyListMutableContainers
															   format: NULL
													 errorDescription: &errorString] retain];
		
		if( !mEntries || ![mEntries isKindOfClass: [NSMutableArray class]] )
		{
			if( outError )
			{
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					errorString, NSLocalizedDescriptionKey,
					nil];
				*outError = [NSError errorWithDomain: NSCocoaErrorDomain code: 0 userInfo: userInfo];
				[errorString release];
			}
			[self release];
			self = nil;
		}
	}
	return self;
}

- (void)dealloc
{
	[mEntries release];
	[super dealloc];
}

- (NSData *)data
{
	return [NSPropertyListSerialization dataFromPropertyList: mEntries format: NSPropertyListXMLFormat_v1_0 errorDescription: NULL];
}

#pragma mark -

- (void)_noteDidChange
{
	[[NSNotificationCenter defaultCenter] postNotificationName: GBLogBookDidChangeNotification
														object: self];
}

- (int)entriesCount
{
	return [mEntries count];
}

- (void)_removeLastEntry
{
	[[mUndoManager prepareWithInvocationTarget: self] makeNewEntry];
	[mEntries removeLastObject];
	[self _noteDidChange];
}

- (void)makeNewEntry
{
	[[mUndoManager prepareWithInvocationTarget: self] _removeLastEntry];
	[mEntries addObject: [NSMutableDictionary dictionary]];
	[self _noteDidChange];
}

- (id)valueForEntry: (int)entryIndex identifier: (NSString *)identifier
{
	if( [identifier isEqualToString: @"number"] )
		return [NSNumber numberWithInt: entryIndex + 1];
	
	return [[mEntries objectAtIndex: entryIndex] objectForKey: identifier];
}

- (void)setValue: (id)value forEntry: (int)entryIndex identifier: (NSString *)identifier
{
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

@end
