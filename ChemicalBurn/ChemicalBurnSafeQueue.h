//
//  ChemicalBurnSafeQueue.h
//  ChemicalBurn
//
//  Created by Michael Ash on 8/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <pthread.h>


@interface ChemicalBurnSafeQueue : NSObject {
	NSMutableArray*		mObjs;
	volatile int32_t	mAddedCount;
	volatile int32_t	mCompletedCount;
	
	pthread_t			mWatchdogThread;
	volatile int32_t	mResetCount;
	
	pthread_mutex_t		mMutex;
	pthread_cond_t		mHasItemsCond;
	pthread_cond_t		mCompletedCond;
}

- (id)init;
- (void)terminate;

- (void)push: (id)obj;
- (id)pop; // blocks when nothing left, multiple threads may do this simultaneously
- (void)completedItem: (id)obj;
- (void)waitForCompletion;

- (void)reset;

@end
