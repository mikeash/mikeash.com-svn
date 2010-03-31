//
//  NSData_OpenCL.m
//  ChordDetect
//
//  Created by Christopher Liscio on 11/13/09.
//  Copyright 2009 SuperMegaUltraGroovy. All rights reserved.
//

#import "NSData_OpenCL.h"
#import "Debug.h"

@interface NSData (OpenCLPrivate)
- (cl_mem)getOpenCLBufferWithFlags:(cl_mem_flags)flags 
    forContext:(SMUGOpenCLContext*)context;
@end

@implementation NSData (OpenCLPrivate)

- (cl_mem)getOpenCLBufferWithFlags:(cl_mem_flags)flags 
    forContext:(SMUGOpenCLContext*)context;
{
    cl_int err;

    cl_mem ret = clCreateBuffer( 
        context.context,
        flags,
        [self length],
        (char*)[self bytes], /* Override const pointer, API blocks writing */
        &err );
    if ( err != CL_SUCCESS ) {
        ERROR( @"Could not create OpenCL buffer of size %d.  Error=%d", [self length] * sizeof(float), err );
        return NULL;
    }

    return ret;
}

@end

@implementation NSData (OpenCL)

- (cl_mem)getOpenCLBufferForReadingInContext:(SMUGOpenCLContext*)context
{
    return [self getOpenCLBufferWithFlags:CL_MEM_READ_ONLY | CL_MEM_USE_HOST_PTR forContext:context];
}

@end

@implementation NSMutableData (OpenCL)

- (cl_mem)getOpenCLBufferForWritingInContext:(SMUGOpenCLContext*)context
{
    return [self getOpenCLBufferWithFlags:CL_MEM_WRITE_ONLY | CL_MEM_USE_HOST_PTR forContext:context];
}

- (void)scheduleReadOfBuffer:(cl_mem)buf fromContext:(SMUGOpenCLContext*)context waitUntilDone:(BOOL)waitUntilDone;
{
    cl_int err = clEnqueueReadBuffer( 
        context.commandQueue, 
        buf, 
        waitUntilDone, 
        0, 
        [self length], 
        [self mutableBytes], 
        0, 
        NULL, 
        NULL );
    if ( err != CL_SUCCESS ) {
        ERROR( @"Could not schedule read of buffer. Error=%d", err );
    }
}

@end
