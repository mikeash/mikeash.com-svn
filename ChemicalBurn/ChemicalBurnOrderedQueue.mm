//
//  ChemicalBurnOrderedQueue.m
//  ChemicalBurn
//
//  Created by Michael Ash on 7/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ChemicalBurnOrderedQueue.h"

#import <algorithm>


struct CBOQNode {
	id obj;
	unsigned val;
};

static bool NodeLessThan( struct CBOQNode &n1, struct CBOQNode &n2 )
{
	if( n1.val != n2.val )
		return n1.val > n2.val;
	else
		return (unsigned)n1.obj < (unsigned)n2.obj;
}

@implementation ChemicalBurnOrderedQueue

- init
{
	if( ( self = [super init] ) )
	{
		mCount = 0;
		mCapacity = 100;
		mObjs = (struct CBOQNode *)malloc( mCapacity * sizeof( *mObjs ) );
	}
	return self;
}

- (void)dealloc
{
	free( mObjs );
	
	[super dealloc];
}

#pragma mark -

- (void)buildheap
{
	std::make_heap( mObjs, mObjs + mCount, NodeLessThan );
	mHeapified = YES;
}

#pragma mark -

- (unsigned)count
{
	return mCount;
}

- (void)addObject: (id)obj value: (unsigned)val
{
	mCount++;
	if( mCount > mCapacity )
	{
		mCapacity *= 2;
		mObjs = (struct CBOQNode *)realloc( mObjs, mCapacity * sizeof( *mObjs ) );
	}
	
	mObjs[mCount - 1].obj = obj;
	mObjs[mCount - 1].val = val;
	
	if( mHeapified )
		std::push_heap( mObjs, mObjs + mCount, NodeLessThan );
}

- (id)pop
{
	if( !mHeapified )
	{
		[self buildheap];
	}
	
	std::pop_heap( mObjs, mObjs + mCount, NodeLessThan );
	mCount--;
	return mObjs[mCount].obj;
}

- (NSString *)description
{
	NSMutableString *str = [NSMutableString string];
	
	[str appendString: @"ChemicalBurnOrderedQueue = (\n"];
	unsigned i;
	for( i = 0; i < mCount; i++ )
		[str appendFormat: @"\t%@ = %u\n", mObjs[i].obj, mObjs[i].val];
	[str appendString: @")\n"];
	
	return str;
}

@end
