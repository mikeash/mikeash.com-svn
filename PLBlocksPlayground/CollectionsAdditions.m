//
//  CollectionsAdditions.m
//  PLBlocksPlayground
//
//  Created by Michael Ash on 8/9/09.
//

#import "CollectionsAdditions.h"


@implementation NSArray (CollectionsAdditions)

- (void)do: (void (^)(id obj))block
{
    for(id obj in self)
        block(obj);
}

- (NSArray *)select: (BOOL (^)(id obj))block
{
    NSMutableArray *new = [NSMutableArray array];
    for(id obj in self)
        if(block(obj))
            [new addObject: obj];
    return new;
}

- (NSArray *)map: (id (^)(id obj))block
{
    NSMutableArray *new = [NSMutableArray array];
    for(id obj in self)
    {
        id newObj = block(obj);
        [new addObject: newObj ? newObj : [NSNull null]];
    }
    return new;
}

@end
