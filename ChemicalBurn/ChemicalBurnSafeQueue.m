//
//  ChemicalBurnSafeQueue.m
//  ChemicalBurn
//
//  Created by Michael Ash on 8/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ChemicalBurnSafeQueue.h"

#import <libkern/OSAtomic.h>
#import <unistd.h>

#define WATCHDOG 1

#define PTHREAD_ERROR_CHECK( x ) do { \
	int PTHREAD_ERR = x; \
	if( PTHREAD_ERR ) \
	{ \
		NSLog( @"%s:%d: %s returned error %d", __FILE__, __LINE__, #x, PTHREAD_ERR ); \
		exit( 1 ); \
	} \
} while( 0 )


@implementation ChemicalBurnSafeQueue

#if WATCHDOG
static void WatchdogTimeout( ChemicalBurnSafeQueue *queue )
{
	[NSAutoreleasePool new];
	
	NSLog( @"Watchdog timed out, getting sample..." );
	
	NSString *outPath = [NSHomeDirectory() stringByAppendingPathComponent: @"ChemicalBurn watchdog timeout sample.txt"];
	NSArray *args = [NSArray arrayWithObjects:
		[NSString stringWithFormat: @"%d", getpid()],
		@"10",
		@"-file",
		outPath,
		nil];
	
	NSTask *task = [NSTask launchedTaskWithLaunchPath: @"/usr/bin/sample" arguments: args];
	[task waitUntilExit];
	
	NSLog( @"Sample finished, adding current state..." );
	
	NSString *stateStr = [NSString stringWithFormat:
		@"addedCount = %d\n"
		@"completedCount = %d\n"
		@"resetCount = %d\n"
		@"\n----------\n\n",
		queue->mAddedCount,
		queue->mCompletedCount,
		queue->mResetCount];
	
	NSData *stateData = [stateStr dataUsingEncoding: NSUTF8StringEncoding];
	NSData *fileData = [NSData dataWithContentsOfFile: outPath];
	NSMutableData *newStateData = [NSMutableData data];
	[newStateData appendData: stateData];
	[newStateData appendData: fileData];
	[newStateData writeToFile: outPath atomically: YES];
	
	NSLog( @"Done, exiting" );
	abort();
}

static void *Watchdog( void *ctx )
{
	ChemicalBurnSafeQueue *queue = ctx;
	int32_t oldCount = queue->mResetCount;
	while( queue->mResetCount != -1 )
	{
		NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
		while( [NSDate timeIntervalSinceReferenceDate] - startTime < 30.0 && queue->mResetCount != -1 )
			sleep( 1 );
		
		int32_t newCount = queue->mResetCount;
		if( queue->mResetCount != -1 && newCount == oldCount )
			WatchdogTimeout( queue );
		
		oldCount = newCount;
	}
	
	return NULL;
}

- (void)_spawnWatchdog
{
	PTHREAD_ERROR_CHECK( pthread_create( &mWatchdogThread, NULL, Watchdog, self ) );
}
#endif

- (id)init
{
	if( ( self = [super init] ) )
	{
		mObjs = [[NSMutableArray alloc] init];
		PTHREAD_ERROR_CHECK( pthread_mutex_init( &mMutex, NULL ) );
		PTHREAD_ERROR_CHECK( pthread_cond_init( &mHasItemsCond, NULL ) );
		PTHREAD_ERROR_CHECK( pthread_cond_init( &mCompletedCond, NULL ) );
		
#if WATCHDOG
		[self _spawnWatchdog];
#endif
	}
	return self;
}

- (void)terminate
{
	mResetCount = -1;
#if WATCHDOG
	pthread_join( mWatchdogThread, NULL );
#endif
}

- (void)dealloc
{
	[mObjs release];
	pthread_mutex_destroy( &mMutex );
	pthread_cond_destroy( &mHasItemsCond );
	pthread_cond_destroy( &mCompletedCond );
	
	[super dealloc];
}

- (void)push: (id)obj
{
	PTHREAD_ERROR_CHECK( pthread_mutex_lock( &mMutex ) );
	[mObjs addObject: obj];
	mAddedCount++;
	PTHREAD_ERROR_CHECK( pthread_mutex_unlock( &mMutex ) );
}

- (id)pop
{
	id obj;
	
	PTHREAD_ERROR_CHECK( pthread_mutex_lock( &mMutex ) );
	while( [mObjs count] == 0 )
		PTHREAD_ERROR_CHECK( pthread_cond_wait( &mHasItemsCond, &mMutex ) );
	obj = [[[mObjs lastObject] retain] autorelease];
	[mObjs removeLastObject];
	PTHREAD_ERROR_CHECK( pthread_mutex_unlock( &mMutex ) );
	
	return obj;
}

- (void)completedItem: (id)obj
{
	PTHREAD_ERROR_CHECK( pthread_mutex_lock( &mMutex ) );
	mCompletedCount++;
	if( mCompletedCount >= mAddedCount )
		PTHREAD_ERROR_CHECK( pthread_cond_signal( &mCompletedCond ) );
	PTHREAD_ERROR_CHECK( pthread_mutex_unlock( &mMutex ) );
	
}

- (void)waitForCompletion
{
	PTHREAD_ERROR_CHECK( pthread_mutex_lock( &mMutex ) );
	
	if( [mObjs count] == 1 )
		PTHREAD_ERROR_CHECK( pthread_cond_signal( &mHasItemsCond ) );
	else
		PTHREAD_ERROR_CHECK( pthread_cond_broadcast( &mHasItemsCond ) );
	
	while( mAddedCount > mCompletedCount )
		PTHREAD_ERROR_CHECK( pthread_cond_wait( &mCompletedCond, &mMutex ) );
	
	PTHREAD_ERROR_CHECK( pthread_mutex_unlock( &mMutex ) );
}

- (void)reset
{
	PTHREAD_ERROR_CHECK( pthread_mutex_lock( &mMutex ) );
	
	[mObjs removeAllObjects];
	mAddedCount = 0;
	mCompletedCount = 0;
	mResetCount++;
	if( mResetCount > 1000000000 )
		mResetCount = 1;
	
	PTHREAD_ERROR_CHECK( pthread_mutex_unlock( &mMutex ) );
}

@end
