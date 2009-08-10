//
//  SheetAdditions.h
//  PLBlocksPlayground
//
//  Created by Michael Ash on 8/9/09.
//  Copyright 2009 Rogue Amoeba Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSApplication (SheetAdditions)

- (void)beginSheet: (NSWindow *)sheet modalForWindow:(NSWindow *)docWindow didEndBlock: (void (^)(NSInteger returnCode))block;

@end
