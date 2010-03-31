//
//  SMUGOpenCLKernel.h
//  ChordDetect
//
//  Created by Christopher Liscio on 11/11/09.
//  Copyright 2009 SuperMegaUltraGroovy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenCL/OpenCL.h>

@interface SMUGOpenCLKernel : NSObject {
    cl_kernel mKernel;
}

- (id)initWithKernel:(cl_kernel)kernel;

@property (readonly,assign) cl_kernel kernel;

- (cl_int)setArgument:(cl_uint)arg withSize:(size_t)size data:(void*)ptr;

@end
