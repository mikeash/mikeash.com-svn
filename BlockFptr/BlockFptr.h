//
//  BlockFptr.h
//  BlockFptr
//
//  Created by Michael Ash on 2/8/10.
//

#import <Foundation/Foundation.h>


@interface BlockFptr : NSObject
{
    void *_fptr;
}

+ (id)fptrWithBlock: (id)block;
- (id)initWithBlock: (id)block;

- (void *)fptr;

@end

// C API
void *CreateBlockFptr(id block);
void DestroyBlockFptr(void *blockFptr);

// a mix; this returns an "autoreleased" fptr, nice for inline use in one-shots
void *AutoBlockPtr(id block);
