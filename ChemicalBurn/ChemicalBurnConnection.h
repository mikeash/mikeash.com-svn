//
//  ChemicalBurnConnection.h
//  ChemicalBurn
//
//  Created by Michael Ash on 7/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <libkern/OSAtomic.h>


enum { kConnectionTrafficWeight, kConnectionDistanceWeight };
enum {
	kConnectionWeightLinear,
	kConnectionWeightSqrt,
	kConnectionWeightSqr,
	kConnectionWeightExp,
	kConnectionWeightLog,
	kConnectionWeightBell // applies to traffic only
};

#define ChemicalBurnConnectionGetCost( c ) ((c)->mCachedCost == 0xFFFFFFFF ? [(c) cost] : (c)->mCachedCost)

@class ChemicalBurnNode;
@class ChemicalBurnPackage;

@interface ChemicalBurnConnection : NSObject {
	ChemicalBurnNode*	mNode1;
	ChemicalBurnNode*	mNode2;
	
	double				mWeight;
	
	volatile int32_t	mNumPackages;
	BOOL				mWillRemove;
	
	@public
	unsigned			mCachedCost;
}

+ (void)setCurve: (int)curve forWeight: (int)weight;

+ connectionWithNode: (ChemicalBurnNode *)node1 andNode: (ChemicalBurnNode *)node2;

- initWithNode: (ChemicalBurnNode *)node1 andNode: (ChemicalBurnNode *)node2;

- (ChemicalBurnNode *)node1;
- (ChemicalBurnNode *)node2;
- (ChemicalBurnNode *)otherNodeFor: (ChemicalBurnNode *)node;
- (BOOL)containsNode: (ChemicalBurnNode *)node;
- (void)incrementWeight;
- (void)decrementWeight;

// the add/remove methods can get called from routing threads
// so they have to be thread-safe
- (void)addPackage: (ChemicalBurnPackage *)pkg;
- (void)removePackage: (ChemicalBurnPackage *)pkg;
- (BOOL)hasPackages;

- (void)setWillRemove;
- (BOOL)willRemove;

- (double)weight;
- (unsigned)cost;
- (float)length;

- (void)draw;
- (void)drawGL;

@end
