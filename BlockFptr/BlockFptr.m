#import <Foundation/Foundation.h>
#include <sys/types.h>
#include <sys/mman.h>


void CallBlock(void)
{
    void *block = (void *)0xdeadbeefcafebabeULL;
    void (*fptr)(void) = *(void **)(block + 16);
    fptr();
}

extern char Trampoline;
extern char TrampolineEnd;

void *gblockPtr;

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    int captured = 3;
    captured += 8;
    id block = ^(int a, int b, int c, int d, int e, int f, int g, int h, int i) {
        NSLog(@"3");
        printf("hello world! %d\n", captured);
        printf("params: %x %x %x %x %x %x %x %x %x\n", a, b, c, d, e, f, g, h, i);
        NSLog(@"4");
    };
    gblockPtr = block;
    
#if 1
    int trampolineLength = &TrampolineEnd - &Trampoline;
    int addrOffset;
    uint64_t magic = 0xdeadbeefcafebabeULL;
    for(addrOffset = 0; addrOffset <= trampolineLength - sizeof(uint64_t); addrOffset++)
        if(*((uint64_t *)(&Trampoline + addrOffset)) == magic)
            break;
    void *trampoline = malloc(4096 * 100);
    memcpy(trampoline, &Trampoline, trampolineLength);
    *((void **)(trampoline + addrOffset)) = &block;
    
    int err = mprotect(trampoline, trampolineLength, PROT_READ | PROT_EXEC);
    if(err)
        perror("mprotect");
    NSLog(@"1 %p", trampoline);
#else
    void *trampoline = &Trampoline;
#endif
    ((void (*)(int, int, int, int, int, int, int, int, int))trampoline)(0xdead0001, 0xdead0002, 0xdead0003, 0xdead0004, 0xdead0005, 0xdead0006, 0xdead0007, 0xdead0008, 0xdead0009);
    NSLog(@"2");
    
    [pool release];
    return 0;
}
