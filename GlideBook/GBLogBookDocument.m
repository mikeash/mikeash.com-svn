//
//  GBLogBookDocument.m
//  GlideBook
//
//  Created by Michael Ash on 4/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GBLogBookDocument.h"

#import "GBLogBook.h"


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
}

#pragma mark -

- (void)_logbookChanged
{
	[mTableView reloadData];
}

- (IBAction)addNewEntry: (id)sender
{
	[mLogBook makeNewEntry];
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
