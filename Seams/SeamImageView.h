//
//  SeamImageView.h
//  Seams
//
//  Created by Michael Ash on 8/26/07.
//  Copyright 2007 Rogue Amoeba Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SeamImageView : NSView
{
	id					mDelegate;
	NSBitmapImageRep*	mRep;
	NSRect				mImageRect;
}

- (void)setDelegate: (id)delegate;
- (void)setRep: (NSBitmapImageRep *)rep;

@end

@interface NSObject (SeamImageViewDelegate)

- (void)mouseDownAtPoint: (NSPoint)p;
- (void)mouseUpAtPoint: (NSPoint)p;

@end
