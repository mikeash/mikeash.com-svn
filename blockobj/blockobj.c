#include <Block.h>
#include <malloc/malloc.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>


#define Alloc(classname) New ## classname(sizeof(struct classname))

struct RootObject
{
    void (^retain)(void);
    void (^release)(void);
    void (^dealloc)(void);
    
    struct String *(^copyDescription)(void);
    int (^isEqual)(struct RootObject *);
};

struct String
{
    struct RootObject parent;
    
    struct String *(^initWithFormat)(char *fmt, ...);
    const char *(^cstring)(void);
};

struct String *NewString(size_t size);

struct RootObject *NewRootObject(size_t size)
{
    // "ivars"
    __block int retainCount = 1;
    
    // make the object
    struct RootObject *self = calloc(size, 1);
    
    // "methods"
    self->retain = Block_copy(^{ retainCount++; });
    self->release = Block_copy(^{
        retainCount--;
        if(retainCount <= 0)
            self->dealloc();
    });
    self->dealloc = Block_copy(^{
        size_t size = malloc_size(self);
        for(void **methodPtr = (void **)self; *methodPtr && ((intptr_t)methodPtr + sizeof(*methodPtr) - 1 - (intptr_t)self) < size; methodPtr++)
            Block_release(*methodPtr);
        free(self);
    });
    self->copyDescription = Block_copy(^{
        return Alloc(String)->initWithFormat("<Object %p>", self);
    });
    
    return self;
}

struct String *NewString(size_t size)
{
    __block char *str = NULL;
    
    struct String *self = (void *)NewRootObject(size);
    
    // override parent methods
    Block_release(self->parent.copyDescription);
    self->parent.copyDescription = Block_copy(^{
        self->parent.retain();
        return self;
    });
    
    void (^superdealloc)(void) = self->parent.dealloc;
    self->parent.dealloc = Block_copy(^{
        free(str);
        superdealloc();
    });
    Block_release(superdealloc);
    
    // more methods
    self->initWithFormat = Block_copy(^(char *fmt, ...){
        va_list args;
        va_start(args, fmt);
        vasprintf(&str, fmt, args);
        va_end(args);
        
        return self;
    });
    self->cstring = Block_copy(^{ return (const char *)str; });
    
    return self;
}

struct MyObject
{
    struct RootObject parent;
    
    struct MyObject *(^initWithNumbers)(int a, int b);
};

struct MyObject *NewMyObject(size_t size)
{
    __block int numbers[2];
    
    struct MyObject *self = (void *)NewRootObject(size);
    
    // override parent methods
    Block_release(self->parent.copyDescription);
    self->parent.copyDescription = Block_copy(^{
        return Alloc(String)->initWithFormat("<MyObject %d %d>", numbers[0], numbers[1]);
    });
    
    self->initWithNumbers = Block_copy(^(int a, int b){
        numbers[0] = a;
        numbers[1] = b;
        return self;
    });
    
    return self;
}

int main(int argc, char **argv)
{
    // basic instantiation/destruction
    struct RootObject *obj = Alloc(RootObject);
    obj->release();
    
    // make sure dealloc is really getting called
    obj = Alloc(RootObject);
    void (^olddealloc)(void) = obj->dealloc;
    obj->dealloc = Block_copy(^{
        printf("dealloc was called!\n");
        olddealloc();
    });
    obj->release();
    Block_release(olddealloc);
    
    // retain counts
    obj = Alloc(RootObject);
    obj->retain();
    obj->retain();
    obj->retain();
    obj->release();
    obj->release();
    obj->release();
    obj->release();
    
    // description
    obj = Alloc(RootObject);
    struct String *description = obj->copyDescription();
    printf("obj is %s\n", description->cstring());
    description->parent.release();
    obj->release();
    
    // custom class
    struct MyObject *myobj = Alloc(MyObject);
    myobj->initWithNumbers(42, 65535);
    description = myobj->parent.copyDescription();
    printf("myobj is %s\n", description->cstring());
    description->parent.release();
    myobj->parent.release();
    
    return 0;
}
