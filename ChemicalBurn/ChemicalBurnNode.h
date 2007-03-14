//
//  ChemicalBurnNode.h
//  ChemicalBurn
//
//  Created by Michael Ash on 7/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// threading support: we store node costs and prevsinline while route finding
// because that's a lot faster, but that conflicts with multithreading
// so we have a table, and allow each thread to get an ID
// this means we have a strict limit on how many threads can run the
// route finder at once
// we try to scale this number as the number of processors, but if the router
// tries to run more, chaos will ensue

// these can be used as a get or a set (by assigning to)
#define NODE_COST( threadID, node ) (((ChemicalBurnNode *)node)->mPerThread[threadID].cost)
#define NODE_PREV( threadID, node ) (((ChemicalBurnNode *)node)->mPerThread[threadID].prev)

// the key parameter allows multiple independent views to share IDs
// IDs will count up from 0 based on the unique key passed in
int NodeGetThreadID( void *key );
void NodeThreadIDCleanup( void *key );


@class ChemicalBurnNode;
struct ChemicalBurnNodePerThread {
	unsigned 			cost;
	ChemicalBurnNode*	prev;
};

@interface ChemicalBurnNode : NSObject {
	unsigned 			mID;
	NSPoint 			mPos;
	
	@public
	struct ChemicalBurnNodePerThread	mPerThread[0];
}

+ (int)numRoutingThreads;

- initWithPos: (NSPoint)pos;

- (unsigned)id;
- (NSPoint)pos;
- (void)draw;
- (void)drawGL;

@end
