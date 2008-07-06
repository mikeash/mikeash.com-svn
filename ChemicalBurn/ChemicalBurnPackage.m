//
//  ChemicalBurnPackage.m
//  ChemicalBurn
//
//  Created by Michael Ash on 7/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ChemicalBurnPackage.h"

#import <ScreenSaver/ScreenSaverView.h>
#import <OpenGL/GL.h>

#import "ChemicalBurnConnection.h"
#import "ChemicalBurnNode.h"


@implementation ChemicalBurnPackage

- initWithSource: (ChemicalBurnNode *)source destination: (ChemicalBurnNode *)destination startStep: (unsigned)startStep
{
	if( ( self = [super init] ) )
	{
		mSource = [source retain];
		mDestination = destination;
		mStartStep = startStep;
		
		mR = SSRandomFloatBetween( 0, 1 );
		mG = SSRandomFloatBetween( 0, 1 );
		mB = SSRandomFloatBetween( 0, 1 );
		
		mSpeed = SSRandomFloatBetween( 0.5, 2.0 );
		
		mProportion = 1.0;
	}
	return self;
}

- (void)dealloc
{
	[mSource release];
	[super dealloc];
}


- (void)setConnection: (ChemicalBurnConnection *)connection forward: (BOOL)forward
{
	[mCurConnection removePackage: self];
	mCurConnection = connection;
	[mCurConnection addPackage: self];
	
	mForward = forward;
	mProportion = 0.0;
}

- (void)setDestination: (ChemicalBurnNode *)destination
{
	mDestination = destination;
}

- (ChemicalBurnNode *)destination
{
	return mDestination;
}

- (ChemicalBurnConnection *)curConnection
{
	return mCurConnection;
}

- (ChemicalBurnNode *)curConnectionDestination
{
	return mForward ? [mCurConnection node2] : [mCurConnection node1];
}

- (ChemicalBurnNode *)curNode
{
	if( mProportion < 1.0 )
		return nil;
	
	ChemicalBurnNode *n = [self curConnectionDestination];
	if( !n )
		n = mSource;
	return n;
}

- (unsigned)startStep
{
	return mStartStep;
}

- (void)step
{
	if( mProportion < 1.0 )
	{
		float length = [mCurConnection length];
		
		if( length > 0.0 )
			mProportion += mSpeed * [mCurConnection weight] / length;
		else
			mProportion = 1.0;
		
		mProportion = MIN( mProportion, 1.0 );
	}
}

- (void)setPackageOfDeath
{
	mIsPackageOfDeath = YES;
	mR = 1;
	mG = 0;
	mB = 0;
}

- (BOOL)isPackageOfDeath
{
	return mIsPackageOfDeath;
}

- (void)setSpeed: (float)speed
{
	mSpeed = speed;
}

- (void)draw
{
	NSPoint p1 = [[mCurConnection node1] pos];
	NSPoint p2 = [[mCurConnection node2] pos];
	
	float proportion = mForward ? mProportion : 1.0 - mProportion;
	
	NSPoint p = { 	p1.x * (1.0 - proportion) + p2.x * proportion,
					p1.y * (1.0 - proportion) + p2.y * proportion };
	
	[[NSColor grayColor] setFill];
	[NSBezierPath fillRect: NSMakeRect( p.x - 2, p.y - 2, 4, 4 )];
	
	/*
	NSPoint destP = [mDestination pos];
	float dx = destP.x - p.x;
	float dy = destP.y - p.y;
	float len = sqrtf( dx * dx + dy * dy );
	
	if( len > 0 )
	{
		dx = dx / len * 10;
		dy = dy / len * 10;
		
		[[NSColor redColor] setStroke];
		[NSBezierPath strokeLineFromPoint: p toPoint: NSMakePoint( p.x + dx, p.y + dy )];
	}
	 */
}

- (void)drawGL
{
	NSPoint p;
	
	if( mCurConnection )
	{
		NSPoint p1 = [[mCurConnection node1] pos];
		NSPoint p2 = [[mCurConnection node2] pos];
		
		float proportion = mForward ? mProportion : 1.0 - mProportion;
		
		p.x = p1.x * (1.0 - proportion) + p2.x * proportion;
		p.y = p1.y * (1.0 - proportion) + p2.y * proportion;
	}
	else
	{
		p = [mSource pos];
	}
	
	float size = mIsPackageOfDeath ? 4.0 : 2.0;
	
	glLineWidth( 0.5 );
	
	int i;
	for( i = 0; i < 2; i++ )
	{
		glColor4f( mR, mG, mB, 1.0 );
		glBegin( i == 1
				 ? GL_LINE_LOOP
				 : mIsPackageOfDeath
				 ? GL_TRIANGLES
				 : GL_QUADS );
		
		glVertex2f( p.x - size, p.y - size );
		if( mIsPackageOfDeath )
		{
			glVertex2f( p.x, p.y + size );
		}
		else
		{
			glVertex2f( p.x - size, p.y + size );
			glVertex2f( p.x + size, p.y + size );
		}
		glVertex2f( p.x + size, p.y - size );
		glEnd();
	}
}

@end
