//
//  GBFilterWindowController.m
//  GlideBook
//
//  Created by Michael Ash on 2/8/09.
//  Copyright 2009 Rogue Amoeba Software, LLC. All rights reserved.
//

#import "GBFilterWindowController.h"

#import "GBLogBookDocument.h"


@interface GBFilterWindowController ()

@property NSWindow *oldMainWindow;

@end


@implementation GBFilterWindowController

@synthesize oldMainWindow = _oldMainWindow;

- (id)init
{
	self = [super initWithWindowNibName: @"GBFilterWindow"];
	return self;
}

- (void)windowDidLoad
{
	[_predicateEditor addRow: self];
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector( _mainWindowChanged )
												 name: NSWindowDidBecomeMainNotification
											   object: nil];
}

- (id)_documentIfRespondsToSetPredicateForWindow: (NSWindow *)window
{
	id document = [[window windowController] document];
	if( [document respondsToSelector: @selector( setFilterPredicate: )] )
		return document;
	else
		return nil;
}

- (void)_setPredicate
{
	[[self _documentIfRespondsToSetPredicateForWindow: [NSApp mainWindow]] setFilterPredicate: [_predicateEditor objectValue]];
}

- (void)_removePredicate
{
	[[self _documentIfRespondsToSetPredicateForWindow: _oldMainWindow] setFilterPredicate: nil];
}

- (void)_mainWindowChanged
{
	[self _removePredicate];
	[self _setPredicate];
	[self setOldMainWindow: [NSApp mainWindow]];
}

- (IBAction)predicateChanged: (id)sender
{
	[self _setPredicate];
}

@end
