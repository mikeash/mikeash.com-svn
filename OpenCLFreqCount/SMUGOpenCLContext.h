//
//  SMUGOpenCLContext.h
//  ChordDetect
//
//  Created by Christopher Liscio on 11/11/09.
//  Copyright 2009 SuperMegaUltraGroovy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenCL/OpenCL.h>

typedef NSUInteger SMUGOpenCLDeviceType;

@class SMUGOpenCLKernel;

@interface SMUGOpenCLContext : NSObject {
    cl_context mContext;
    cl_device_id mDeviceID;
    cl_device_type mDeviceType;
    cl_command_queue mCommandQueue;
}

- (id)initCPUContext;
- (id)initGPUContext;

- (size_t)workgroupSizeForKernel:(SMUGOpenCLKernel*)kernel;
- (void)enqueueKernel:(SMUGOpenCLKernel*)kernel 
    withWorkDimensions:(cl_uint)work_dim 
    globalWorkSize:(const size_t*)global
    localWorkSize:(const size_t*)local;
- (void)finish;
    
@property (readonly,assign) cl_context context;
@property (readonly,assign) cl_device_id deviceId;
@property (readonly,assign) cl_device_type deviceType;
@property (readonly,assign) cl_command_queue commandQueue;

@end
