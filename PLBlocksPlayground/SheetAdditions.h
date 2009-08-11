//
//  SheetAdditions.h
//  PLBlocksPlayground
//
//  Created by Michael Ash on 8/9/09.
//

#import <Cocoa/Cocoa.h>


@interface NSApplication (SheetAdditions)

- (void)beginSheet: (NSWindow *)sheet modalForWindow:(NSWindow *)docWindow didEndBlock: (void (^)(NSInteger returnCode))block;

@end
