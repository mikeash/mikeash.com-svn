//
//  GBLogBookDocument.m
//  GlideBook
//
//  Created by Michael Ash on 4/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GBLogBookDocument.h"

#import <objc/objc-runtime.h>

#import "GBDataView.h"
#import "GBFilter.h"
#import "GBLogBook.h"


@interface GBLogBookDocument (Private)

- (void)_logbookChanged: (NSNotification *)note;
- (void)_setDataView: (GBDataView *)dataView;

@end


@implementation GBLogBookDocument

- (id)initWithType: (NSString *)typeName error: (NSError **)outError
{
	if( (self = [super initWithType: typeName error: outError]) )
	{
		mLogBook = [[GBLogBook alloc] init];
		[self setFilterPredicate: [NSPredicate predicateWithValue: YES]];
	}
	return self;
}

- (NSString *)windowNibName
{
    return @"GBLogBookDocument";
}

- (NSData *)dataOfType: (NSString *)typeName error: (NSError **)outError
{
    return [mLogBook data];
}

- (BOOL)readFromData: (NSData *)data ofType: (NSString *)typeName error: (NSError **)outError
{
	mLogBook = [[GBLogBook alloc] initWithData: data error: outError];
	[self setFilterPredicate: [NSPredicate predicateWithValue: YES]];
	
	return mLogBook != nil;
}

- (void)_setupToolbarItems
{
	NSSize size = [mSearchField frame].size;
	[mSearchToolbarItem setView: mSearchField];
	[mSearchToolbarItem setMinSize: size];
	[mSearchToolbarItem setMaxSize: NSMakeSize( 300, size.height )];
}

- (void)awakeFromNib
{
	[self _setupToolbarItems];
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector( _logbookChanged: )
												 name: GBLogBookDidChangeNotification
											   object: mLogBook];
	[self _logbookChanged: nil];
}

- (IBAction)addNewEntry: (id)sender
{
	[mDataView makeNewEntry];
}

- (IBAction)delete: (id)sender
{
	int row = [mTableView selectedRow];
	if( row >= 0 )
	{
		[mDataView removeEntryAtIndex: row];
		[mTableView selectRowIndexes: [NSIndexSet indexSet] byExtendingSelection: NO];
	}
}

- (BOOL)_validate_delete: (id)obj
{
	return [mTableView selectedRow] >= 0;
}

- (IBAction)filter: (id)sender
{
	[self setFilterPredicate: [GBFilter filterWithString: [mSearchField stringValue]]];
}

- (void)setFilterPredicate: (NSPredicate *)predicate
{
	[self _setDataView: [GBDataView dataViewWithUndoManager: [self undoManager]
													logBook: mLogBook
												  predicate: predicate]];
	[self _logbookChanged: nil];
}

@end

@implementation GBLogBookDocument (Private)

- (id)_totalForIdentifier: (NSString *)identifier
{
	static NSSet *totalIDs = nil;
	if( !totalIDs )
		totalIDs = [[NSSet alloc] initWithObjects: @"dual_time", @"pilot_in_command_time", @"solo_time", @"instruction_given_time", @"total_time", nil];
	
	if( ![totalIDs containsObject: identifier] )
		return @"";
	else
		return [NSNumber numberWithInt: [mDataView totalForIdentifier: identifier]];
}

- (void)_logbookChanged: (NSNotification *)note
{
	[mTableView reloadData];
	
	NSIndexSet *indexes = [[note userInfo] objectForKey: @"indexes"];
	if( indexes )
	{
		int index = [mDataView entryIndexForLogbookIndex: [indexes lastIndex]];
		[mTableView scrollRowToVisible: index + 1];
	}
}

- (void)_setDataView: (GBDataView *)dataView
{
	mDataView = dataView;
}

- (int)numberOfRowsInTableView: (NSTableView *)tableView
{
	return [mDataView entriesCount] + 1;
}

- (id)tableView: (NSTableView *)tableView objectValueForTableColumn: (NSTableColumn *)tableColumn row: (int)row
{
	if( row == [mDataView entriesCount] )
		return [self _totalForIdentifier: [tableColumn identifier]];
	else
		return [mDataView valueForEntry: row identifier: [tableColumn identifier]];
}

- (void)tableView: (NSTableView *)tableView setObjectValue: (id)object forTableColumn: (NSTableColumn *)tableColumn row: (int)row
{
	[mDataView setValue: object forEntry: row identifier: [tableColumn identifier]];
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	if( [cell isKindOfClass: [NSButtonCell class]] )
		[cell setTransparent: row == [mDataView entriesCount]];
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	return row != [mDataView entriesCount];
}

#pragma mark -

- (BOOL)validateUserInterfaceItem: (id <NSValidatedUserInterfaceItem>)item
{
	NSString *actionStr = NSStringFromSelector( [item action] );
	NSString *selStr = [@"_validate_" stringByAppendingString: actionStr];
	SEL sel = NSSelectorFromString( selStr );
	
	if( [self respondsToSelector: sel] )
		return ((BOOL (*)(id self, SEL _cmd, id item))objc_msgSend)(self, sel, item);
	
	return [super validateUserInterfaceItem: item];
}

@end
