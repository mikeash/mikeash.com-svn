//
//  GBLogBookDocument.m
//  GlideBook
//
//  Created by Michael Ash on 4/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GBLogBookDocument.h"

#import "GBDataView.h"
#import "GBFilter.h"
#import "GBLogBook.h"


@interface GBLogBookDocument (Private)

- (void)_logbookChanged;
- (void)_setFilterString: (NSString *)str;

@end


@implementation GBLogBookDocument

- (id)initWithType: (NSString *)typeName error: (NSError **)outError
{
	if( (self = [super initWithType: typeName error: outError]) )
	{
		mLogBook = [[GBLogBook alloc] init];
		[self _setFilterString: nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[mLogBook release];
	[mDataView release];
	
	[super dealloc];
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
	[self _setFilterString: nil];

	return mLogBook != nil;
}

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector( _logbookChanged )
												 name: GBLogBookDidChangeNotification
											   object: mLogBook];
	[self _logbookChanged];
}

- (IBAction)addNewEntry: (id)sender
{
	[mDataView makeNewEntry];
}

- (IBAction)filter: (id)sender
{
	[self _setFilterString: [mSearchField stringValue]];
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

- (void)_logbookChanged
{
	[mTableView reloadData];
}

- (void)_setDataView: (GBDataView *)dataView
{
	if( dataView != mDataView )
	{
		[mDataView release];
		mDataView = [dataView retain];
	}
}

- (void)_setFilterString: (NSString *)str
{
	[self _setDataView: [GBDataView dataViewWithUndoManager: [self undoManager]
													logBook: mLogBook
													 filter: [GBFilter filterWithString: str]]];
	[self _logbookChanged];
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
	if( row == [mDataView entriesCount] )
		NSLog( @"Will display cell %@ in last row", cell );
	if( [cell isKindOfClass: [NSButtonCell class]] )
		[cell setTransparent: row == [mDataView entriesCount]];
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	return row != [mDataView entriesCount];
}

@end
