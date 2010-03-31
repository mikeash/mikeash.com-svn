//
//  SMUGOpenCLProgram.h
//  ChordDetect
//
//  Created by Christopher Liscio on 11/11/09.
//  Copyright 2009 SuperMegaUltraGroovy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenCL/OpenCL.h>

@class SMUGOpenCLContext;
@class SMUGOpenCLKernel;

@interface SMUGOpenCLProgram : NSObject {
    SMUGOpenCLContext *mContext;
    cl_program mProgram;
}

- (id)initWithContext:(SMUGOpenCLContext*)context sourceString:(NSString*)source;

- (SMUGOpenCLKernel*)kernelNamed:(NSString*)kernelName;

@end
