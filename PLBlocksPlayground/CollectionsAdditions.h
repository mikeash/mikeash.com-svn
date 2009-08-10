//
//  CollectionsAdditions.h
//  PLBlocksPlayground
//
//  Created by Michael Ash on 8/9/09.
//  Copyright 2009 Rogue Amoeba Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSArray (CollectionsAdditions)

- (void)do: (void (^)(id obj))block;
- (NSArray *)select: (BOOL (^)(id obj))block;
- (NSArray *)map: (id (^)(id obj))block;

@end
