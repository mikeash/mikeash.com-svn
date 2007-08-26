//
//  SeamImageView.m
//  Seams
//
//  Created by Michael Ash on 8/26/07.
//  Copyright 2007 Rogue Amoeba Software, LLC. All rights reserved.
//

#import "SeamImageView.h"


@implementation SeamImageView

- (void)dealloc
{
	[mRep release];
	
	[super dealloc];
}

- (void)setDelegate: (id)delegate
{
	mDelegate = delegate;
}

- (NSRect)_imageRectGetScale: (float *)outScale
{
	NSRect bounds = [self bounds];
	
	float xScale = NSWidth( bounds ) / [mRep pixelsWide];
	float yScale = NSHeight( bounds ) / [mRep pixelsHigh];
	float scale = MIN( xScale, yScale );
	
	NSRect imageRect;
	imageRect.size.width = [mRep pixelsWide] * scale;
	imageRect.size.height = [mRep pixelsHigh] * scale;
	
	float dx = NSWidth( bounds ) - NSWidth( imageRect );
	float dy = NSHeight( bounds ) - NSHeight( imageRect );
	
	imageRect.origin.x = dx / 2.0;
	imageRect.origin.y = dy / 2.0;
	
	if( outScale )
		*outScale = scale;
	
	return imageRect;
}

- (void)setRep: (NSBitmapImageRep *)rep
{
	if( rep != mRep )
	{
		[mRep release];
		mRep = [rep retain];
		
		[self setNeedsDisplay: YES];
	}
}

- (void)drawRect: (NSRect)rect
{
	[mRep drawInRect: [self _imageRectGetScale: NULL]];
}

- (NSPoint)_imagePointForEvent: (NSEvent *)event
{
	NSPoint p = [event locationInWindow];
	p = [self convertPoint: p fromView: nil];
	
	float scale;
	NSRect r = [self _imageRectGetScale: &scale];
	
	p.x -= NSMinX( r );
	p.y -= NSMinY( r );
	
	p.x /= scale;
	p.y /= scale;
	
	p.y = [mRep pixelsHigh] - p.y - 1;
	
	return p;
}

- (void)mouseDown: (NSEvent *)event
{
	NSPoint p = [self _imagePointForEvent: event];
	[mDelegate mouseDownAtPoint: p];
}

- (void)mouseUp: (NSEvent *)event
{
	NSPoint p = [self _imagePointForEvent: event];
	[mDelegate mouseUpAtPoint: p];
}

@end
