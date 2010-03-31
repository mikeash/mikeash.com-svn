//
//  SMUGOpenCLKernel.m
//  ChordDetect
//
//  Created by Christopher Liscio on 11/11/09.
//  Copyright 2009 SuperMegaUltraGroovy. All rights reserved.
//

#import "SMUGOpenCLKernel.h"


@implementation SMUGOpenCLKernel

@synthesize kernel=mKernel;

- (id)initWithKernel:(cl_kernel)kernel;
{
    if ( !( self = [super init] ) ) {
        return nil;
    }
    
    mKernel = kernel;
    
    return self;
}

- (cl_int)setArgument:(cl_uint)arg withSize:(size_t)size data:(void*)ptr
{
    return clSetKernelArg( mKernel, arg, size, ptr );
}

- (void)dealloc
{
    clReleaseKernel( mKernel );
    [super dealloc];
}

@end
