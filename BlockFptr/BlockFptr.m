#import "BlockFptr.h"

#include <dispatch/dispatch.h>
#include <libkern/osatomic.h>
#include <sys/types.h>
#include <sys/mman.h>


@implementation BlockFptr

+ (id)fptrWithBlock: (id)block
{
    return [[[self alloc] initWithBlock: block] autorelease];
}

- (id)initWithBlock: (id)block
{
    if((self = [super init]))
    {
        _fptr = CreateBlockFptr(block);
    }
    return self;
}

- (id)init
{
    NSLog(@"You cannot call -[%@ %@], use -initWithBlock: instead", [self class], NSStringFromSelector(_cmd));
    [self autorelease];
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (void)dealloc
{
    DestroyBlockFptr(_fptr);
    [super dealloc];
}

- (void *)fptr
{
    return _fptr;
}

@end

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

static OSQueueHead gFptrCache = OS_ATOMIC_QUEUE_INIT;

// the fptr cache actually caches the block pointer pointers
// because the trampolines themselves are immutable
// block pointer pointers are defined like so
struct QueueElement
{
    // when in the queue, the first field is the required 'next' pointer
    // when in use, the first field is the block pointer
    void *nextPtrOrBlock;
    
    // when in the queue, the second field is to the associated trampoline
    // when in use, the second field is unused
    void *trampoline;
};

// dequeue an fptr, point it to the block
// the block is copied as part of this
static void *DequeueCachedFptr(id block)
{
    struct QueueElement *elt = OSAtomicDequeue(&gFptrCache, 0);
    if(!elt)
        return NULL;
    
    elt->nextPtrOrBlock = [block copy];
    return elt->trampoline;
}

// enqueue an fptr
// the associated block is released as part of this
static void EnqueueCachedFptr(void *trampoline)
{
    struct QueueElement **eltPtr = trampoline + TrampolineAddrOffset();
    struct QueueElement *elt = *eltPtr;
    id block = elt->nextPtrOrBlock;
    
    [(id)block release];
    
    OSAtomicEnqueue(&gFptrCache, elt, 0);
}

void CreateNewFptrsAndEnqueue(void)
{
    int trampolineLength = &TrampolineEnd - &Trampoline;
    int addrOffset = TrampolineAddrOffset();
    
    int pageSize = getpagesize();
    int howmany = pageSize / trampolineLength;
    void *page = valloc(pageSize);
    
    struct QueueElement *elts = malloc(howmany * sizeof(*elts));
    
    for(int i = 0; i < howmany; i++)
    {
        void *trampoline = page + i * trampolineLength;
        memcpy(trampoline, &Trampoline, trampolineLength);
        
        elts[i].nextPtrOrBlock = NULL;
        elts[i].trampoline = trampoline;
        *((void **)(trampoline + addrOffset)) = &elts[i];
    }
    
    int err = mprotect(page, pageSize, PROT_READ | PROT_EXEC);
    if(err)
        perror("mprotect");
    
    for(int i = 0; i < howmany; i++)
    {
        void *trampoline = page + i * trampolineLength;
        EnqueueCachedFptr(trampoline);
    }
}

void *CreateBlockFptr(id block)
{
    void *fptr;
    while(!(fptr = DequeueCachedFptr(block)))
        CreateNewFptrsAndEnqueue();
    return fptr;
}

void DestroyBlockFptr(void *blockFptr)
{
    EnqueueCachedFptr(blockFptr);
}

void *AutoBlockFptr(id block)
{
    return [[BlockFptr fptrWithBlock: block] fptr];
}

/*
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
    
    BlockFptr *fptr = [[BlockFptr alloc] initWithBlock: block];
    ((void (*)(int, int, int, int, int))[fptr fptr])(0xdead0001, 0xdead0002, 0xdead0003, 0xdead0004, 0xdead0005);
    
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < 10000; i++)
    {
        BlockFptr *fptr = [[BlockFptr alloc] initWithBlock: block];
        [array addObject: fptr];
        [fptr release];
    }
    [array removeAllObjects];
    
    [pool release];
    return 0;
}
*/
