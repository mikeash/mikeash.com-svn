//
//  NSData_OpenCL.h
//  ChordDetect
//
//  Created by Christopher Liscio on 11/13/09.
//  Copyright 2009 SuperMegaUltraGroovy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenCL/OpenCL.h>
#import "SMUGOpenCLContext.h"

@interface NSData (OpenCL)
- (cl_mem)getOpenCLBufferForReadingInContext:(SMUGOpenCLContext*)context;
@end

@interface NSMutableData (OpenCL)
- (cl_mem)getOpenCLBufferForWritingInContext:(SMUGOpenCLContext*)context;
- (void)scheduleReadOfBuffer:(cl_mem)buf fromContext:(SMUGOpenCLContext*)context waitUntilDone:(BOOL)waitUntilDone;
@end
