#import <Foundation/Foundation.h>

#include <dispatch/dispatch.h>
#include <sys/types.h>
#include <sys/mman.h>


// for debugging purposes only
void DumpStack(uint64_t rbp, uint64_t rsp)
{
    uint64_t bottom = MIN(rbp, rsp) - 32;
    uint64_t top = MAX(rbp, rsp) + 32;
    
    for(uint64_t ptr = top; ptr >= bottom; ptr -= 8)
    {
        char *marker = "        ";
        if(ptr == rbp)
            marker = "%rbp -->";
        if(ptr == rsp)
            marker = "%rsp -->";
        fprintf(stderr, "%s 0x%016" PRIx64 ": 0x%016" PRIx64 "\n", marker, ptr, *(uint64_t *)ptr);
    }
}

extern char Trampoline;
extern char TrampolineEnd;

static int TrampolineAddrOffset(void)
{
    static int addrOffset;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        uint64_t magic = 0xdeadbeefcafebabeULL;
        for(addrOffset = 0; addrOffset <= &TrampolineEnd - &Trampoline - sizeof(uint64_t); addrOffset++)
            if(*((uint64_t *)(&Trampoline + addrOffset)) == magic)
                break;
    });
    
    return addrOffset;
}

void *CreateBlockFptr(id block)
{
    int trampolineLength = &TrampolineEnd - &Trampoline;
    int addrOffset = TrampolineAddrOffset();
    
    int pageSize = getpagesize();
    void *trampoline = valloc(pageSize);
    memcpy(trampoline, &Trampoline, trampolineLength);
    
    void **blockPtr = malloc(sizeof(*blockPtr));
    *blockPtr = [block copy];
    
    *((void **)(trampoline + addrOffset)) = blockPtr;
    
    int err = mprotect(trampoline, pageSize, PROT_READ | PROT_EXEC);
    if(err)
        perror("mprotect");
    
    return trampoline;
}

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    int captured = 3;

    id block = ^(int a, int b, int c, int d, int e) {
        printf("hello world!\n");
        printf("captured value is %d (should be 3)\n", captured);
        printf("params: %x %x %x %x %x\n", a, b, c, d, e);
    };
    
#if 0
    // shortcut straight into trampoline code for debugging purposes
    static void *gblockPtr;
    gblockPtr = block;
    void *trampoline = &Trampoline;
#else
    void *trampoline = CreateBlockFptr(block);
#endif
    ((void (*)(int, int, int, int, int))trampoline)(0xdead0001, 0xdead0002, 0xdead0003, 0xdead0004, 0xdead0005);
    
    [pool release];
    return 0;
}
