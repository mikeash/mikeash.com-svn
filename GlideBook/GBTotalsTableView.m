//
//  GBTotalsTableView.m
//  GlideBook
//
//  Created by Michael Ash on 5/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GBTotalsTableView.h"


@interface NSTableView (PrivateDelegateSupportEvil)

- (void)_delegateWillDisplayCell: (id)cell forColumn: (NSTableColumn *)column row: (int)row;
- (NSRect)clipForDrawingRow: (int)row column: (NSTableColumn *)column;

@end

@implementation GBTotalsTableView

- (void)awakeFromNib
{
	if( [[self superclass] instancesRespondToSelector: _cmd] )
		[super awakeFromNib];
	
	[[[self enclosingScrollView] contentView] setCopiesOnScroll: NO];
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector( _windowMainStatusChanged )
												 name: NSWindowDidBecomeMainNotification
											   object: [self window]];
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector( _windowMainStatusChanged )
												 name: NSWindowDidResignMainNotification
											   object: [self window]];
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector( _windowMainStatusChanged )
												 name: NSWindowDidBecomeKeyNotification
											   object: [self window]];
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector( _windowMainStatusChanged )
												 name: NSWindowDidResignKeyNotification
											   object: [self window]];
}

- (void)_windowMainStatusChanged
{
	[self setNeedsDisplay: YES];
}

- (NSRect)_GBTotalRowRect
{
	NSRect rowRect = [self rectOfRow: [self numberOfRows] - 1];
	NSRect visRect = [self visibleRect];
	float deltaY = NSMaxY( visRect ) - NSMaxY( rowRect );
	return NSOffsetRect( rowRect, 0, deltaY );
}

- (void)drawRow: (int)row clipRect: (NSRect)rect
{
	if( row != [self numberOfRows] - 1 )
		[super drawRow: row clipRect: rect];
}

- (void)_delegateWillDisplayCell: (id)cell forColumn: (NSTableColumn *)column row: (int)row
{
//	int lastRow = [self numberOfRows] - 1;
//	if( row == lastRow )
//	{
//		if( !mDidDrawLastRowBackground )
//		{
//			[[NSColor whiteColor] setFill];
//			[NSBezierPath fillRect: [self rectOfRow: lastRow]];
//			mDidDrawLastRowBackground = YES;
//		}
//	}
	[super _delegateWillDisplayCell: cell forColumn: column row: row];
}

- (NSRect)clipForDrawingRow: (int)row column: (NSTableColumn *)column
{
	NSRect rect = [super clipForDrawingRow: row column: column];
	NSLog( @"%s: %@", __func__, NSStringFromRect( rect ) );
	return rect;
}

- (void)drawRect: (NSRect)rect
{
	[super drawRect: rect];
	
	NSRect totalRowRect = [self _GBTotalRowRect];
	
	float lineY = NSMinY( totalRowRect ) - 0.5;
	NSPoint p1 = NSMakePoint( NSMinX( totalRowRect ), lineY );
	NSPoint p2 = NSMakePoint( NSMaxX( totalRowRect ), lineY );
	[[NSColor grayColor] setStroke];
	[NSBezierPath strokeLineFromPoint: p1 toPoint: p2];
	
	int lastRow = [self numberOfRows] - 1;
	NSRect lastRowRect = [self rectOfRow: lastRow];
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform translateXBy: 0 yBy: NSMaxY( totalRowRect ) - NSMaxY( lastRowRect )];
	[transform concat];
	
	mDidDrawLastRowBackground = NO;
	[[NSColor whiteColor] setFill];
	[NSBezierPath fillRect: [self rectOfRow: lastRow]];
	[super drawRow: lastRow clipRect: [self bounds]];
}

- (void)highlightSelectionInClipRect: (NSRect)rect
{
	int lastRow = [self numberOfRows] - 1;
	NSIndexSet *indexes = [self selectedRowIndexes];
	if( [indexes containsIndex: lastRow] )
	{
		NSMutableIndexSet *mut = [indexes mutableCopy];
		[mut removeIndex: lastRow];
		[self selectRowIndexes: mut byExtendingSelection: NO];
	}
	[super highlightSelectionInClipRect: rect];
}

- (void)mouseDown: (NSEvent *)event
{
	NSPoint pt = [self convertPoint: [event locationInWindow] fromView: nil];
	if( !NSPointInRect( pt, [self _GBTotalRowRect] ) )
		[super mouseDown: event];
}

@end
