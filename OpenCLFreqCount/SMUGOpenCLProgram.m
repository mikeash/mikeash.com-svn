//
//  SMUGOpenCLProgram.m
//  ChordDetect
//
//  Created by Christopher Liscio on 11/11/09.
//  Copyright 2009 SuperMegaUltraGroovy. All rights reserved.
//

#import "SMUGOpenCLProgram.h"
#import "SMUGOpenCLContext.h"
#import "SMUGOpenCLKernel.h"
#import "Debug.h"

@implementation SMUGOpenCLProgram

- (id)initWithContext:(SMUGOpenCLContext*)context sourceString:(NSString*)source;
{
    if ( !( self = [super init] ) ) {
        return nil;
    }
    
    mContext = [context retain];
    
    const char *sourceString = [source UTF8String];
    
    cl_int err;
    cl_program program = clCreateProgramWithSource(
        mContext.context, 
        1,                  // Only 1 program specified
        &sourceString, 
        NULL,               // Passing a null-term string
        &err );

    if ( err != CL_SUCCESS ) {
        ERROR( @"Could not create program. Error=%d.", err );
        return nil;
    }

    mProgram = program;
    
    err = clBuildProgram( mProgram, 0, NULL, NULL, NULL, NULL );
    if ( err != CL_SUCCESS ) {
        ERROR( @"Could not build program. Error=%d.", err );
        
        size_t len;
        err = clGetProgramBuildInfo( 
            mProgram,
            mContext.deviceId,
            CL_PROGRAM_BUILD_LOG,
            0,
            NULL,
            &len );
        
        NSMutableData *data = [NSMutableData dataWithLength:len+1];
        
        err = clGetProgramBuildInfo( 
            mProgram,
            mContext.deviceId,
            CL_PROGRAM_BUILD_LOG,
            [data length],
            [data mutableBytes],
            &len );
        
        NSString *resultString = [[[NSString alloc] initWithData:data 
            encoding:NSUTF8StringEncoding] autorelease];
        
        NSLog( @"Build log:\n%@", resultString );
        
        clReleaseProgram( mProgram );
        return nil;
    }

    return self;
}

- (SMUGOpenCLKernel*)kernelNamed:(NSString*)kernelName;
{
    cl_int err;
    cl_kernel kernel = clCreateKernel( mProgram, [kernelName UTF8String], &err );
    if ( err != CL_SUCCESS ) {
        return nil;
    }
    return [[[SMUGOpenCLKernel alloc] initWithKernel:kernel] autorelease];
}

- (void)dealloc
{
    if ( mProgram ) {
        clReleaseProgram( mProgram );
        mProgram = nil;
    }
    [mContext release], mContext = nil;
    
    [super dealloc];
}

@end
