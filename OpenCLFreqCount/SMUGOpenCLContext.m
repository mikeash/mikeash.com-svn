//
//  SMUGOpenCLContext.m
//  ChordDetect
//
//  Created by Christopher Liscio on 11/11/09.
//  Copyright 2009 SuperMegaUltraGroovy. All rights reserved.
//

#import "SMUGOpenCLContext.h"
#import "SMUGOpenCLKernel.h"
#import "Debug.h"

@implementation SMUGOpenCLContext

@synthesize context=mContext;
@synthesize deviceId=mDeviceID;
@synthesize deviceType=mDeviceType;
@synthesize commandQueue=mCommandQueue;

- (id)initSimpleContextWithDeviceType:(SMUGOpenCLDeviceType)inDeviceType;
{
    if ( !( self = [super init] ) ) {
        return nil;
    }
    
    mDeviceType = inDeviceType;
    
    cl_device_id device_id;
    cl_int err = clGetDeviceIDs( NULL, mDeviceType, 1, &device_id, NULL );
    if ( err != CL_SUCCESS ) {
        ERROR( @"Error retrieving OpenCL device ID for type %d", mDeviceType );
        return nil;
    }
    
    mDeviceID = device_id;
    
    cl_context context = clCreateContext( NULL, 1, &mDeviceID, NULL, NULL, &err );
    if ( err != CL_SUCCESS ) {
        ERROR( @"Error retrieving OpenCL device ID for type %d", mDeviceType );
        return nil;
    }
    
    mContext = context;
    
    cl_command_queue command_queue = clCreateCommandQueue( mContext , mDeviceID, 0, &err );
    if ( err != CL_SUCCESS ) {
        ERROR( @"Could not create command queue for device %d", mDeviceID );
        clReleaseContext( mContext );
        return nil;
    }
    
    mCommandQueue = command_queue;
    
    return self;
}

- (id)initCPUContext;
{
    return [self initSimpleContextWithDeviceType:CL_DEVICE_TYPE_CPU];
}

- (id)initGPUContext;
{
    return [self initSimpleContextWithDeviceType:CL_DEVICE_TYPE_GPU];
}

#pragma mark Public API

- (size_t)workgroupSizeForKernel:(SMUGOpenCLKernel*)kernel
{
    size_t workgroupSize;
    cl_int err = clGetKernelWorkGroupInfo( 
        kernel.kernel, 
        mDeviceID, 
        CL_KERNEL_WORK_GROUP_SIZE, 
        sizeof(size_t), 
        &workgroupSize, 
        NULL );
    if ( err != CL_SUCCESS ) {
        ERROR( @"Could not get work group size for device %d", mDeviceID );
        return 0;
    }
    return workgroupSize;
}

- (void)enqueueKernel:(SMUGOpenCLKernel*)kernel 
    withWorkDimensions:(cl_uint)work_dim 
    globalWorkSize:(const size_t*)global
    localWorkSize:(const size_t*)local
{
    cl_int err;
    err = clEnqueueNDRangeKernel( mCommandQueue, 
        kernel.kernel, 
        work_dim, 
        NULL, 
        global, 
        local, 
        0, 
        NULL, 
        NULL );
    if ( err != CL_SUCCESS ) {
        ERROR( @"Could not enqueue kernel.  Error %d", err );
    }
}

- (void)finish
{
    clFinish( mCommandQueue );
}



- (void)dealloc
{
    if ( mCommandQueue ) {
        clReleaseCommandQueue( mCommandQueue );
    }
    if ( mContext ) {
        clReleaseContext( mContext );
    }
    
    [super dealloc];
}

@end
