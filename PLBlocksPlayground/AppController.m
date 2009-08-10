//
//  AppController.m
//  PLBlocksPlayground
//
//  Created by Michael Ash on 8/9/09.
//  Copyright 2009 Rogue Amoeba Software, LLC. All rights reserved.
//

#import "AppController.h"

#import "BlocksAdditions.h"
#import "CollectionsAdditions.h"
#import "SheetAdditions.h"


@implementation AppController

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName: NSApplicationDidBecomeActiveNotification object: nil block: ^(NSNotification *note){ NSLog(@"Did become active"); }];
    [[NSNotificationCenter defaultCenter] addObserverForName: NSApplicationDidResignActiveNotification object: nil block: ^(NSNotification *note){ NSLog(@"Did resign active"); }];
    
    NSString *s1 = [NSMutableString string];
    CFStringRef s2 = (void *)[NSMutableString string];
    
    NSLog(@"%d %d", [s1 retainCount], [(id)s2 retainCount]);
    id block = ^{ s1, s2; };
    NSLog(@"%d %d", [s1 retainCount], [(id)s2 retainCount]);
    block = [block copy];
    NSLog(@"%d %d", [s1 retainCount], [(id)s2 retainCount]);
    [block release];
    NSLog(@"%d %d", [s1 retainCount], [(id)s2 retainCount]);
}

- (IBAction)showSheet: (id)sender
{
    [NSApp beginSheet: _sheet modalForWindow: _window didEndBlock: ^(NSInteger ret){
        NSLog(@"Sheet ended with code %ld", (long)ret);
    }];
}

- (IBAction)okSheet: (id)sender
{
    [NSApp endSheet: _sheet returnCode: NSOKButton];
    [_sheet orderOut: nil];
}

- (IBAction)cancelSheet: (id)sender
{
    [NSApp endSheet: _sheet returnCode: NSCancelButton];
    [_sheet orderOut: nil];
}

- (IBAction)do: (id)sender
{
    NSArray *testArray = [NSArray arrayWithObjects: @"1", @"2", @"3", nil];
    [testArray do: ^(id obj){ NSLog(@"%@", obj); }];
    
    NSLog(@"%@", [testArray select: ^ BOOL (id obj){ return [obj intValue] > 1; }]);
    NSLog(@"%@", [testArray map: ^(id obj){ return [NSString stringWithFormat: @"<%@>", obj]; }]);
}

- (IBAction)blocks: (id)sender
{
    RunInBackground(^{
        WithAutoreleasePool(^{
            NSLog(@"Current thread: %@  Main thread: %@", [NSThread currentThread], [NSThread mainThread]);
            RunOnMainThread(YES, ^{
                NSLog(@"Current thread: %@  Main thread: %@", [NSThread currentThread], [NSThread mainThread]);
                RunAfterDelay(1, ^{
                    NSLog(@"Delayed log");
                });
            });
        });
    });
    
    NSLock *lock = [[NSLock alloc] init];
    [lock whileLocked: ^{ NSLog(@"locked"); }];
    [lock release];
}

- (IBAction)parallel: (id)sender
{
    Parallelized(20, ^(int i){ NSLog(@"Iteration: %d", i); });
}

- (IBAction)url: (id)sender
{
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: @"http://www.google.com/"]];
    [NSURLConnection sendAsynchronousRequest: request completionBlock: ^(NSData *data, NSURLResponse *response, NSError *error){
        NSLog(@"data: %ld bytes  response: %@  error: %@", (long)[data length], response, error);
    }];
}

@end
