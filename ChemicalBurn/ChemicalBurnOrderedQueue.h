//
//  ChemicalBurnOrderedQueue.h
//  ChemicalBurn
//
//  Created by Michael Ash on 7/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// provides any-in smallest-out functionality
// size is based on an unsigned that's passed in
// you can add new nodes but you can only remove via pop
// nothing is retained

@interface ChemicalBurnOrderedQueue : NSObject {
	struct CBOQNode*	mObjs;
	unsigned			mCount;
	unsigned			mCapacity;
	
	BOOL				mHeapified;
}

- init;

- (unsigned)count;
- (void)addObject: (id)obj value: (unsigned)val;
- (id)pop;

@end
