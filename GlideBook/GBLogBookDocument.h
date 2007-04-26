//
//  GBLogBookDocument.h
//  GlideBook
//
//  Created by Michael Ash on 4/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class GBLogBook;

@interface GBLogBookDocument : NSDocument
{
	IBOutlet NSTableView*		mTableView;
	IBOutlet NSTextFieldCell*	mTotalDualCell;
	IBOutlet NSTextFieldCell*	mTotalPICCell;
	IBOutlet NSTextFieldCell*	mTotalSoloCell;
	IBOutlet NSTextFieldCell*	mTotalInstCell;
	IBOutlet NSTextFieldCell*	mTotalTotalCell;
	
	GBLogBook*		mLogBook;
}

- (IBAction)addNewEntry: (id)sender;

@end
