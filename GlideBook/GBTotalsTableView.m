//
//  GBTotalsTableView.m
//  GlideBook
//
//  Created by Michael Ash on 5/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GBTotalsTableView.h"


@implementation GBTotalsTableView

- (void)awakeFromNib
{
	if( [[self superclass] instancesRespondToSelector: _cmd] )
		[super awakeFromNib];
	
	[[[self enclosingScrollView] contentView] setCopiesOnScroll: NO];
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

- (void)drawRect: (NSRect)rect
{
	[super drawRect: rect];
	
	NSRect rectToDraw = [self _GBTotalRowRect];
	
	float lineY = NSMinY( rectToDraw ) - 0.5;
	NSPoint p1 = NSMakePoint( NSMinX( rectToDraw ), lineY );
	NSPoint p2 = NSMakePoint( NSMaxX( rectToDraw ), lineY );
	[[NSColor grayColor] setStroke];
	[NSBezierPath strokeLineFromPoint: p1 toPoint: p2];
	
	int lastRow = [self numberOfRows] - 1;
	NSRect lastRowRect = [self rectOfRow: lastRow];
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform translateXBy: 0 yBy: NSMaxY( rectToDraw ) - NSMaxY( lastRowRect )];
	[transform concat];
	
	[[NSColor whiteColor] setFill];
	[NSBezierPath fillRect: lastRowRect];
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
		[mut release];
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
