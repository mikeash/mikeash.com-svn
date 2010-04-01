// gcc -W -Wall --std=c99 -g -framework Foundation -framework OpenCL *.m -o freqcount

#import <Foundation/Foundation.h>

#import "NSData_OpenCL.h"
#import "SMUGOpenCLContext.h"
#import "SMUGOpenCLKernel.h"
#import "SMUGOpenCLProgram.h"


#define ERROR(fmt, ...) do { NSLog(@"line %d: " fmt, __LINE__, ## __VA_ARGS__); exit(1); } while(0)


static void WithAutoreleasePool(void (^b)(void))
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    b();
    [pool release];
}


static NSString *CLFreqCountSourceString(void)
{
    NSError *err;
    NSString *s = [NSString stringWithContentsOfFile: @"freqcount.cl" encoding: NSUTF8StringEncoding error: &err];
    if(!s)
        ERROR("couldn't load OpenCL program: %@", err);
    return s;
}

static NSData *CLFreqCount(NSData *inData)
{
    NSMutableData *data = [NSMutableData dataWithData: inData];
    
    // pad data to multiple of 256
    NSUInteger dataLength = [data length];
    NSUInteger paddedLength = dataLength + 255 - (dataLength + 255) % 256;
    NSUInteger pad = paddedLength - dataLength;
    [data setLength: paddedLength];
    
    // create large output area
    NSMutableData *largeOutput = [NSMutableData dataWithLength: paddedLength * 2];
    // and the final totals area
    NSMutableData *freqCount = [NSMutableData dataWithLength: 256 * sizeof(uint32_t)];
    
    SMUGOpenCLContext *context = [[SMUGOpenCLContext alloc] initCPUContext];
    SMUGOpenCLProgram *program = [[SMUGOpenCLProgram alloc] initWithContext: context sourceString: CLFreqCountSourceString()];
    SMUGOpenCLKernel *freqCountKernel = [program kernelNamed: @"freqcount"];
    SMUGOpenCLKernel *freqSumKernel = [program kernelNamed: @"freqsum"];
    
    cl_mem dataCL = [data getOpenCLBufferForReadingInContext: context];
    cl_mem largeOutputCL = [largeOutput getOpenCLBufferForWritingInContext: context];
    cl_mem freqCountCL = [freqCount getOpenCLBufferForWritingInContext: context];
    
    cl_int err;
    err = [freqCountKernel setArgument: 0 withSize: sizeof(dataCL) data: &dataCL];
    if(err)
        ERROR("OpenCL error: %lld", (long long)err);
    err = [freqCountKernel setArgument: 1 withSize: sizeof(largeOutputCL) data: &largeOutputCL];
    if(err)
        ERROR("OpenCL error: %lld", (long long)err);
    
    cl_uint sumCount = paddedLength / 256;
    err = [freqSumKernel setArgument: 0 withSize: sizeof(sumCount) data: &sumCount];
    if(err)
        ERROR("OpenCL error: %lld", (long long)err);
    err = [freqSumKernel setArgument: 1 withSize: sizeof(largeOutputCL) data: &largeOutputCL];
    if(err)
        ERROR("OpenCL error: %lld", (long long)err);
    err = [freqSumKernel setArgument: 2 withSize: sizeof(freqCountCL) data: &freqCountCL];
    if(err)
        ERROR("OpenCL error: %lld", (long long)err);
    
    size_t globalSizeCount[] = { paddedLength / 256 };
    size_t localSizeCount[] = { [context workgroupSizeForKernel: freqCountKernel] };
    [context enqueueKernel: freqCountKernel
        withWorkDimensions: 1
            globalWorkSize: globalSizeCount
             localWorkSize: localSizeCount];
    
    size_t globalSizeSum[] = { 256 };
    size_t localSizeSum[] = { [context workgroupSizeForKernel: freqSumKernel] };
    [context enqueueKernel: freqSumKernel
        withWorkDimensions: 1
            globalWorkSize: globalSizeSum
             localWorkSize: localSizeSum];
    
    [context finish];
    
    uint32_t *freqs = [freqCount mutableBytes];
    // compensate for the padding
    freqs[0] -= pad;
    
    [program release];
    [context release];
    
    return freqCount;
}

static NSData *SimpleFreqCount(NSData *inData)
{
    NSMutableData *freqCount = [NSMutableData dataWithLength: 256 * sizeof(uint32_t)];
    uint32_t *freqs = [freqCount mutableBytes];
    
    const unsigned char *ptr = [inData bytes];
    NSUInteger len = [inData length];
    for(NSUInteger i = 0; i < len; i++)
        freqs[ptr[i]]++;
    
    return freqCount;
}

static void PrintFreqs(NSData *freqsData)
{
    const uint32_t *freqs = [freqsData bytes];
    for(unsigned i = 0; i < 256; i++)
        if(freqs[i])
            printf("% 3d '%c': %d\n", i, i, freqs[i]);
}

static void Time(NSString *name, void (^block)(void))
{
    NSProcessInfo *pi = [NSProcessInfo processInfo];
    
    NSTimeInterval start = [pi systemUptime];
    block();
    NSTimeInterval end = [pi systemUptime];
    
    NSLog(@"%@ took %f seconds", name, end - start);
}

int main(int argc, char **argv)
{
    WithAutoreleasePool(^{
        if(argc != 2)
            ERROR("usage: %s <file>", argv[0]);
        
        NSString *path = [NSString stringWithUTF8String: argv[1]];
        if(!path)
            ERROR("bad path: %s", argv[1]);
        
        NSError *err;
        NSData *data = [NSData dataWithContentsOfFile: path options: 0 error: &err];
        if(!data)
            ERROR("couldn't read data: %@", err);
        
        __block NSData *clFreqsData;
        Time(@"OpenCL", ^{ clFreqsData = CLFreqCount(data); });
        
        __block NSData *simpleFreqsData;
        Time(@"Regular C", ^{ simpleFreqsData = SimpleFreqCount(data); });
        
        if(![clFreqsData isEqual: simpleFreqsData])
            ERROR("OpenCL produced different frequency data!\nCL: %@\nregular: %@", clFreqsData, simpleFreqsData);
        
        PrintFreqs(clFreqsData);
    });
    
    return 0;
}
