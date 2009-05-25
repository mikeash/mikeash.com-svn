//
//  ChemicalBurnConnection.m
//  ChemicalBurn
//
//  Created by Michael Ash on 7/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ChemicalBurnConnection.h"

#import <OpenGL/GL.h>

#import "ChemicalBurnNode.h"


@implementation ChemicalBurnConnection

static int gTrafficWeight;
static int gDistanceWeight;

+ (void)setCurve: (int)curve forWeight: (int)weight
{
	if( weight == kConnectionTrafficWeight )
		gTrafficWeight = curve;
	else if( weight == kConnectionDistanceWeight )
		gDistanceWeight = curve;
}

+ connectionWithNode: (ChemicalBurnNode *)node1 andNode: (ChemicalBurnNode *)node2;
{
	return [[[self alloc] initWithNode: node1 andNode: node2] autorelease];
}

- initWithNode: (ChemicalBurnNode *)node1 andNode: (ChemicalBurnNode *)node2
{
	if( ( self = [super init] ) )
	{
		if( [node1 id] < [node2 id] )
		{
			mNode1 = node1;
			mNode2 = node2;
		}
		else
		{
			mNode1 = node2;
			mNode2 = node1;
		}
		
		mWeight = 1.0;
		mCachedCost = 0xFFFFFFFF;
	}
	
	return self;
}

- (NSUInteger)hash
{
	unsigned h1 = [mNode1 hash];
	unsigned h2 = [mNode2 hash];
	
	return h1 ^ (((h2 >> 16) & 0xFFFF) | ((h2 & 0xFFFF) << 16));
}

- (BOOL)isEqual: (id)other
{
	if( ![other isKindOfClass: [ChemicalBurnConnection class]] )
		return NO;
	
	return [mNode1 isEqual: [other node1]] && [mNode2 isEqual: [other node2]];
}

- copyWithZone: (NSZone *)zone
{
	return [self retain]; // not quite correct because of the weight, but meh
}

- (ChemicalBurnNode *)node1
{
	return mNode1;
}

- (ChemicalBurnNode *)node2
{
	return mNode2;
}

- (ChemicalBurnNode *)otherNodeFor: (ChemicalBurnNode *)node
{
	return node == mNode1 ? mNode2 : mNode1;
}

- (BOOL)containsNode: (ChemicalBurnNode *)node
{
	return node == mNode1 || node == mNode2;
}

- (void)incrementWeight
{
	mCachedCost = 0xFFFFFFFF;
	mWeight++;
}

- (void)decrementWeight
{
	mCachedCost = 0xFFFFFFFF;
	mWeight = ((mWeight - 1.0 ) * 0.99) + 1.0;
}

- (void)addPackage: (ChemicalBurnPackage *)pkg
{
	OSAtomicIncrement32( (int32_t *)&mNumPackages );
}

- (void)removePackage: (ChemicalBurnPackage *)pkg
{
	OSAtomicDecrement32( (int32_t *)&mNumPackages );
}

- (BOOL)hasPackages
{
	return mNumPackages > 0;
}

- (void)setWillRemove
{
	mCachedCost = 0xFFFFFFFF;
	mWillRemove = YES;
}

- (BOOL)willRemove
{
	return mWillRemove;
}

- (double)weight
{
	switch( gTrafficWeight )
	{
		case kConnectionWeightLinear:
			return mWeight;
		case kConnectionWeightSqrt:
			return sqrt( mWeight );
		case kConnectionWeightSqr:
			return mWeight * mWeight;
		case kConnectionWeightExp:
			return MIN( exp( mWeight / 3 ), 1000000 );
		case kConnectionWeightLog:
			return log( mWeight ) + 1.0;
		case kConnectionWeightBell:
		{
			float adjWeight = mWeight / 3.0 - 2;
			return MAX( 0.01, exp( adjWeight - (adjWeight * adjWeight)/2 ) * 25 );
		}
	}
	
	NSLog( @"%s: unknown weight %d", __func__, gTrafficWeight );
	gTrafficWeight = 0;
	return [self weight];
}

- (unsigned)cost
{
	if( mCachedCost == 0xFFFFFFFF )
	{
		// for willremove connections, cost needs to be
		// low enough that you can pathfind through it as a last resort
		// for packages with no alternative

		mCachedCost = ceil( [self length] / [self weight] ) + 1;
		if( mWillRemove )
			mCachedCost += 0x00FFFFFF;
	}
	return mCachedCost;
}

- (float)length
{
	NSPoint p1 = [mNode1 pos];
	NSPoint p2 = [mNode2 pos];
	
	float dx = p1.x - p2.x;
	float dy = p1.y - p2.y;
	
	float l2 = dx * dx + dy * dy;
	
	switch( gDistanceWeight )
	{
		case kConnectionWeightLinear:
			return sqrtf( l2 );
		case kConnectionWeightSqrt:
			return pow( l2, 0.25 ) * 5;
		case kConnectionWeightSqr:
			return l2 / 25;
		case kConnectionWeightExp:
			return MIN( exp( sqrtf( l2 ) / 10 ) / 3, 1000000 );
		case kConnectionWeightLog:
			return MAX( (log( l2 ) / 2 + 1.0) * 25, 1.0 );
	}
	
	NSLog( @"%s: unknown weight %d", __func__, gDistanceWeight );
	gDistanceWeight = 0;
	return [self length];
}

- (void)draw
{
	float width = MIN( (mWeight - 1.0) / 24, 4.0 );
	
	if( width > 0.1 )
	{
		NSBezierPath *path = [NSBezierPath bezierPath];
		[path moveToPoint: [mNode1 pos]];
		[path lineToPoint: [mNode2 pos]];
		[path setLineWidth: width];
		
		if( mWillRemove )
			[[NSColor redColor] setStroke];
		else
			[[NSColor whiteColor] setStroke];
		[path stroke];
	}
}

- (void)drawGL
{
	float width = MIN( (mWeight - 1.0) / 24, 6.0 );
	
	if( width >= 1.0 / 255.0 )
	{
		NSPoint p1 = [mNode1 pos];
		NSPoint p2 = [mNode2 pos];
		
		// GL doesn't do really small widths smoothly, so we fake it
		// if the width is less than 1, do an actual width of 1, but
		// use the width as alpha on the line
		// otherwise, full white with the specified width
		float realWidth = MAX( width, 1.0 );
		float grayValue = MIN( width, 1.0 );
		
		glLineWidth( realWidth );
		if( mWillRemove )
			glColor4f( 1, 0, 0, grayValue );
		else
			glColor4f( 1, 1, 1, grayValue );
		
		glBegin( GL_LINES );
		
		glVertex2f( p1.x, p1.y );
		glVertex2f( p2.x, p2.y );
		
		glEnd();
	}
}

@end
