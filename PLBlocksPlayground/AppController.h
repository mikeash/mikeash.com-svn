//
//  AppController.h
//  PLBlocksPlayground
//
//  Created by Michael Ash on 8/9/09.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject
{
    IBOutlet NSWindow *_window;
    IBOutlet NSPanel *_sheet;
}

- (IBAction)showSheet: (id)sender;
- (IBAction)okSheet: (id)sender;
- (IBAction)cancelSheet: (id)sender;

- (IBAction)do: (id)sender;
- (IBAction)blocks: (id)sender;
- (IBAction)parallel: (id)sender;
- (IBAction)url: (id)sender;

@end
