//
//  GBLogBookDocument.m
//  GlideBook
//
//  Created by Michael Ash on 4/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GBLogBookDocument.h"

#import "GBLogBook.h"


@interface GBLogBookDocument (Private)

- (void)_logbookChanged;

@end


@implementation GBLogBookDocument

- (id)initWithType: (NSString *)typeName error: (NSError **)outError
{
	if( (self = [super initWithType: typeName error: outError]) )
	{
		mLogBook = [[GBLogBook alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
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
	mLogBook = [[GBLogBook alloc] initWithUndoManager: [self undoManager] data: data error: outError];
	
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
	[mLogBook makeNewEntry];
}

@end

@implementation GBLogBookDocument (Private)

- (void)_updateTotals
{
	int dual = [mLogBook totalForIdentifier: @"dual_time"];
	int pic  = [mLogBook totalForIdentifier: @"pilot_in_command_time"];
	int solo = [mLogBook totalForIdentifier: @"solo_time"];
	int inst = [mLogBook totalForIdentifier: @"instruction_given_time"];
	
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

- (int)numberOfRowsInTableView: (NSTableView *)tableView
{
	return [mLogBook entriesCount];
}

- (id)tableView: (NSTableView *)tableView objectValueForTableColumn: (NSTableColumn *)tableColumn row: (int)row
{
	return [mLogBook valueForEntry: row identifier: [tableColumn identifier]];
}

- (void)tableView: (NSTableView *)tableView setObjectValue: (id)object forTableColumn: (NSTableColumn *)tableColumn row: (int)row
{
	[mLogBook setValue: object forEntry: row identifier: [tableColumn identifier]];
}


@end
