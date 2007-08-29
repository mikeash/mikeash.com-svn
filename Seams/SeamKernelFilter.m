//
//  SeamKernelFilter.m
//  Seams
//
//  Created by Michael Ash on 8/29/07.
//  Copyright 2007 Rogue Amoeba Software, LLC. All rights reserved.
//

#import "SeamKernelFilter.h"


@interface SeamMinPlusFilter : SeamKernelFilter
{
	NSNumber*	y;
}
@end
@interface SeamSliceFilter : SeamKernelFilter
{
	CIImage*	sliceImage;
}
@end

@implementation SeamKernelFilter

static CIKernel *gMinPlusKernel;
static CIKernel *gSliceKernel;

+ (CIKernel *)_kernelForResourceName: (NSString *)name
{
	NSString *path = [[NSBundle mainBundle] pathForResource: name ofType: @"cikernel"];
	NSString *contents = [NSString stringWithContentsOfFile: path];
	
	return [[CIKernel kernelsWithString: contents] objectAtIndex: 0];
}

+ (void)initialize
{
	if( !gMinPlusKernel )
		gMinPlusKernel = [[self _kernelForResourceName: @"minpluskernel"] retain];
	if( !gSliceKernel )
		gSliceKernel = [[self _kernelForResourceName: @"slicekernel"] retain];
}

+ (id)minPlusFilter
{
	return [[[SeamMinPlusFilter alloc] init] autorelease];
}

+ (id)sliceFilter
{
	return [[[SeamSliceFilter alloc] init] autorelease];
}

@end

@implementation SeamMinPlusFilter

- (void)dealloc
{
	[self setValue: nil forKey: @"y"];
	
	[super dealloc];
}

- (CIImage *)outputImage
{
	CISampler *src = [CISampler samplerWithImage: inputImage];
	return [self apply: gMinPlusKernel, src, y, nil];
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
