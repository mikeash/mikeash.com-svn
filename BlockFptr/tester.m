//
//  tester.m
//  BlockFptr
//
//  Created by Michael Ash on 2/8/10.
//


#import "BlockFptr.h"

int main(int argc, char **argv)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    CFArrayCallBacks callbacks = {
        0,
        AutoBlockFptr(^(CFAllocatorRef allocator, const void *value) {
            NSLog(@"retain %@", value);
            return value;
        }),
        AutoBlockFptr(^(CFAllocatorRef allocator, const void *value) {
            NSLog(@"release %@", value);
        }),
        AutoBlockFptr(^(CFAllocatorRef allocator, const void *value) {
            NSLog(@"description of %@", value);
            return [(id)value description];
        }),
        AutoBlockFptr(^(CFAllocatorRef allocator, const void *value1, const void *value2) {
            NSLog(@"equality %@ %@", value1, value2);
            return (Boolean)[(id)value1 isEqual: (id)value2];
        })
    };
      
    CFMutableArrayRef array = CFArrayCreateMutable(NULL, 0, &callbacks);
    CFArrayAppendValue(array, @"first object");
    CFArrayAppendValue(array, @"second object");
    CFArrayRemoveAllValues(array);
    
    [pool release];
}