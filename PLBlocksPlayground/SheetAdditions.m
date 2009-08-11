//
//  SheetAdditions.m
//  PLBlocksPlayground
//
//  Created by Michael Ash on 8/9/09.
//

#import "SheetAdditions.h"


@implementation NSApplication (SheetAdditions)

- (void)beginSheet: (NSWindow *)sheet modalForWindow:(NSWindow *)docWindow didEndBlock: (void (^)(NSInteger returnCode))block
{
    [self beginSheet: sheet modalForWindow: docWindow modalDelegate: self didEndSelector: @selector(my_blockSheetDidEnd:returnCode:contextInfo:) contextInfo: [block copy]];
}

- (void)my_blockSheetDidEnd: (NSWindow *)sheet returnCode: (NSInteger)returnCode contextInfo: (void *)contextInfo
{
    void (^block)(NSInteger returnCode) = contextInfo;
    block(returnCode);
    [block release];
}

@end
