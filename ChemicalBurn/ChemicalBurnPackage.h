//
//  ChemicalBurnPackage.h
//  ChemicalBurn
//
//  Created by Michael Ash on 7/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class ChemicalBurnConnection;
@class ChemicalBurnNode;

@interface ChemicalBurnPackage : NSObject {
	float						mR, mG, mB;
	ChemicalBurnNode*			mSource;
	ChemicalBurnNode*			mDestination;
	ChemicalBurnConnection*		mCurConnection;
	
	unsigned					mStartStep;
	
	float						mSpeed;
	
	float						mProportion;
	BOOL						mForward;
	
	BOOL						mIsPackageOfDeath;
}

- initWithSource: (ChemicalBurnNode *)source destination: (ChemicalBurnNode *)destination startStep: (unsigned)startStep;

- (void)setConnection: (ChemicalBurnConnection *)connection forward: (BOOL)forward;
- (void)setDestination: (ChemicalBurnNode *)destination;
- (ChemicalBurnNode *)destination;
- (ChemicalBurnConnection *)curConnection;
- (ChemicalBurnNode *)curConnectionDestination; // returns next node to transit
- (ChemicalBurnNode *)curNode; // nil if in transit
- (unsigned)startStep;
- (void)step; // only works if in transit

- (void)setPackageOfDeath;
- (BOOL)isPackageOfDeath;

- (void)setSpeed: (float)speed;

- (void)draw;
- (void)drawGL;

@end
