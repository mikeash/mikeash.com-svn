//
//  SeamAppController.h
//  Seams
//
//  Created by Michael Ash on 8/25/07.
//  Copyright 2007 Rogue Amoeba Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class SeamImageView;
@interface SeamAppController : NSObject
{
	IBOutlet SeamImageView*	mImageView;
	
	CIImage*				mImage;
	
	NSRect					mErasureRect;
	
	NSPoint					mDownPoint;
	NSTimer*				mTimer;
}

@end
