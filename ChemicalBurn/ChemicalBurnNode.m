//
//  ChemicalBurnNode.m
//  ChemicalBurn
//
//  Created by Michael Ash on 7/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ChemicalBurnNode.h"

#import <libkern/OSAtomic.h>
#import <OpenGL/GL.h>
#import <pthread.h>


@implementation ChemicalBurnNode

static pthread_key_t gThreadIDKey;

static CFMutableBagRef gIDs;
static pthread_mutex_t gIDMutex;

static unsigned gID = 0;
static int gProcessorCount;

#pragma mark -

int NodeGetThreadID( void *key )
{
	// we store ID + 1 because NULL is used to indicate "does not exist"
	long threadID = (long)pthread_getspecific( gThreadIDKey );
	if( threadID == 0 )
	{
		pthread_mutex_lock( &gIDMutex );
		CFBagAddValue( gIDs, key );
		threadID = CFBagGetCountOfValue( gIDs, key );
		pthread_mutex_unlock( &gIDMutex );
		
		pthread_setspecific( gThreadIDKey, (void *)threadID );
		
		if( threadID > gProcessorCount )
			NSLog( @"Attempted to get ID for thread #%d, more than allowed!", threadID );
	}
	
	return threadID - 1;
}

static void MakeKey( void )
{
	int err = pthread_key_create( &gThreadIDKey, NULL );
	if( err )
		NSLog( @"%s: pthread_key_create returned %d", __func__, err );
}

void NodeThreadIDCleanup( void *key )
{
	while( CFBagGetCountOfValue( gIDs, key ) )
		CFBagRemoveValue( gIDs, key );
}

#pragma mark -

+ (void)initialize
{
	if( self != [ChemicalBurnNode class] )
		return;
	
	MakeKey();
	gIDs = CFBagCreateMutable( NULL, 0, NULL );
	int err = pthread_mutex_init( &gIDMutex, NULL );
	if( err )
		NSLog( @"pthread_mutex_init returned %d", err );
	
	gProcessorCount = MAX( MPProcessors(), 1);
}

+ (int)numRoutingThreads
{
	return gProcessorCount;
}

+ allocWithZone: (NSZone *)zone
{
	unsigned extraBytes = gProcessorCount * sizeof( struct ChemicalBurnNodePerThread );
	return NSAllocateObject( self, extraBytes, zone );
}

- initWithPos: (NSPoint)pos
{
	if( ( self = [super init] ) )
	{
		mID = gID++;
		mPos = pos;
	}
	return self;
}

- (NSUInteger)hash
{
	return mID;
}

- (BOOL)isEqual: (id)other
{
	if( ![other isKindOfClass: [ChemicalBurnNode class]] )
		return NO;
	
	return mID == [other id];
}

- copyWithZone: (NSZone *)zone
{
	return [self retain];
}

- (unsigned)id
{
	return mID;
}

- (NSPoint)pos
{
	return mPos;
}

- (void)draw
{
	[[NSColor whiteColor] setFill];
	[NSBezierPath fillRect: NSMakeRect( mPos.x - 3, mPos.y - 3, 6, 6 )];
}

- (void)drawGL
{
	float size = 3.0;
	glVertex2f( mPos.x - size, mPos.y - size );
	glVertex2f( mPos.x - size, mPos.y + size );
	glVertex2f( mPos.x + size, mPos.y + size );
	glVertex2f( mPos.x + size, mPos.y - size );
}

@end
