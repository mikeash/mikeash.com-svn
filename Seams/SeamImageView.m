//
//  SeamImageView.m
//  Seams
//
//  Created by Michael Ash on 8/26/07.
//  Copyright 2007 Rogue Amoeba Software, LLC. All rights reserved.
//

#import "SeamImageView.h"

#import <QuartzCore/QuartzCore.h>


inline static NSRect CGRectToNS( CGRect r )
{
	return *(NSRect *)&r;
}

inline static CGRect NSRectToCG( NSRect r )
{
	return *(CGRect *)&r;
}

@implementation SeamImageView

- (void)dealloc
{
	[mImage release];
	
	[super dealloc];
}

- (void)setDelegate: (id)delegate
{
	mDelegate = delegate;
}

- (NSRect)_imageRectGetScale: (float *)outScale
{
	NSRect bounds = [self bounds];
	NSRect extent = CGRectToNS( [mImage extent] );
	
	float xScale = NSWidth( bounds ) / NSWidth( extent );
	float yScale = NSHeight( bounds ) / NSHeight( extent );
	float scale = MIN( xScale, yScale );
	
	NSRect imageRect;
	imageRect.size.width = NSWidth( extent ) * scale;
	imageRect.size.height = NSHeight( extent ) * scale;
	
	float dx = NSWidth( bounds ) - NSWidth( imageRect );
	float dy = NSHeight( bounds ) - NSHeight( imageRect );
	
	imageRect.origin.x = dx / 2.0;
	imageRect.origin.y = dy / 2.0;
	
	if( outScale )
		*outScale = scale;
	
	return imageRect;
}

- (void)setImage: (CIImage *)image
{
	if( image != mImage )
	{
		[mImage release];
		mImage = [image retain];
	}
	[self setNeedsDisplay: YES];
}

- (void)drawRect: (NSRect)rect
{
	CIContext *ctx = [[NSGraphicsContext currentContext] CIContext];
	[ctx drawImage: mImage inRect: NSRectToCG( [self _imageRectGetScale: NULL] ) fromRect: [mImage extent]];
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
	
	p.y = CGRectGetHeight( [mImage extent] ) - p.y - 1;
	
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
