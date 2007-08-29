//
//  SeamMaxPlusFilter.m
//  Seams
//
//  Created by Michael Ash on 8/29/07.
//  Copyright 2007 Rogue Amoeba Software, LLC. All rights reserved.
//

#import "SeamKernelFilter.h"


@interface SeamMaxPlusFilter : SeamKernelFilter {} @end
@interface SeamSliceFilter : SeamKernelFilter
{
	CIImage*	sliceImage;
}
@end

@implementation SeamKernelFilter

static CIKernel *gMaxPlusKernel;
static CIKernel *gSliceKernel;

+ (CIKernel *)_kernelForResourceName: (NSString *)name
{
	NSString *path = [[NSBundle mainBundle] pathForResource: name ofType: @"cikernel"];
	NSString *contents = [NSString stringWithContentsOfFile: path];
	
	return [[CIKernel kernelsWithString: contents] objectAtIndex: 0];
}

+ (void)initialize
{
	if( !gMaxPlusKernel )
		gMaxPlusKernel = [[self _kernelForResourceName: @"maxpluskernel"] retain];
	if( !gSliceKernel )
		gSliceKernel = [[self _kernelForResourceName: @"slicekernel"] retain];
}

+ (id)maxPlusFilter
{
	return [[[SeamMaxPlusFilter alloc] init] autorelease];
}

+ (id)sliceFilter
{
	return [[[SeamSliceFilter alloc] init] autorelease];
}

@end

@implementation SeamMaxPlusFilter

- (CIImage *)outputImage
{
	CISampler *src = [CISampler samplerWithImage: inputImage];
	return [self apply: gMaxPlusKernel, src, nil];
}

@end

@implementation SeamSliceFilter

- (CIImage *)outputImage
{
	CISampler *src = [CISampler samplerWithImage: inputImage];
	CISampler *slice = [CISampler samplerWithImage: sliceImage];
	
	return [self apply: gSliceKernel, src, slice, nil];
}

@end
