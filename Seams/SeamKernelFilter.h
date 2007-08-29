//
//  SeamKernelFilter.h
//  Seams
//
//  Created by Michael Ash on 8/29/07.
//  Copyright 2007 Rogue Amoeba Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <QuartzCore/QuartzCore.h>


@interface SeamKernelFilter : CIFilter
{
	CIImage*	inputImage;
	CIKernel*	kernel;
}

+ (id)minPlusFilter;
+ (id)sliceFilter;

@end
