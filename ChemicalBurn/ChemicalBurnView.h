//
//  ChemicalBurnView.h
//  ChemicalBurn
//
//  Created by Michael Ash on 7/10/06.
//  Copyright (c) 2006, __MyCompanyName__. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>


@class ChemicalBurnPackage;
@class ChemicalBurnSafeQueue;

@interface ChemicalBurnView : ScreenSaverView 
{
	NSOpenGLContext*				mGLContext;
	
	NSMutableArray*					mNodes;
	NSMutableArray*					mDestroyNodes;
	NSMutableDictionary*			mNodeConnectionDict; // maps node -> NSMutableArray containing connections
	NSMutableSet*					mPackages;
    
    NSTimer*                        mStepTimer;
	
	int								mNumRoutingThreads;
	ChemicalBurnSafeQueue*  		mPackagesToRoute;
	
	ChemicalBurnPackage*			mPackageOfDeath;
	
	int								mOptimalNodeCount;
	BOOL							mCreateDestroyNodes;
	BOOL							mHasPackageOfDeath;
	
	unsigned						mStep;
	double							mPackageSteps;
	double							mDeliveredPackages;
	
	IBOutlet NSWindow*				mConfigurationWindow;
	IBOutlet NSObjectController*	mConfigurationObjectController;
	IBOutlet NSTextField*			mVersionField;
}

- (IBAction)configurationCancel: (id)sender;
- (IBAction)configurationOK: (id)sender;
- (IBAction)configurationHelp: (id)sender;
- (IBAction)configurationAbout: (id)sender;

- (void)setDefaultValues;
- (void)loadFromUserDefaults;

@end
