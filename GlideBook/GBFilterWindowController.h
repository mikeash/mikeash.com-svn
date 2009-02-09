//
//  GBFilterWindowController.h
//  GlideBook
//
//  Created by Michael Ash on 2/8/09.
//  Copyright 2009 Rogue Amoeba Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GBFilterWindowController : NSWindowController
{
	IBOutlet NSPredicateEditor	*_predicateEditor;
	
	NSWindow *_oldMainWindow;
}

- (IBAction)predicateChanged: (id)sender;

@end
