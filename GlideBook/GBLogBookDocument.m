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

- (void)_updateTotals
{
	int dual = [mDataView totalForIdentifier: @"dual_time"];
	int pic  = [mDataView totalForIdentifier: @"pilot_in_command_time"];
	int solo = [mDataView totalForIdentifier: @"solo_time"];
	int inst = [mDataView totalForIdentifier: @"instruction_given_time"];
	
	[mTotalDualCell setIntValue: dual];
	[mTotalPICCell  setIntValue: pic];
	[mTotalSoloCell setIntValue: solo];
	[mTotalInstCell setIntValue: inst];
	
	[mTotalTotalCell setIntValue: dual + pic + solo + inst];
}

- (void)_logbookChanged
{
	[mTableView reloadData];
	[self _updateTotals];
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
	return [mDataView entriesCount];
}

- (id)tableView: (NSTableView *)tableView objectValueForTableColumn: (NSTableColumn *)tableColumn row: (int)row
{
	return [mDataView valueForEntry: row identifier: [tableColumn identifier]];
}

- (void)tableView: (NSTableView *)tableView setObjectValue: (id)object forTableColumn: (NSTableColumn *)tableColumn row: (int)row
{
	[mDataView setValue: object forEntry: row identifier: [tableColumn identifier]];
}


@end
