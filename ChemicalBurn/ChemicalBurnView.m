//
//  ChemicalBurnView.m
//  ChemicalBurn
//
//  Created by Michael Ash on 7/10/06.
//  Copyright (c) 2006, __MyCompanyName__. All rights reserved.
//

#import "ChemicalBurnView.h"

#import <libkern/OSAtomic.h>

#import <OpenGL/GL.h>
#import <OpenGL/glu.h>

#import <unistd.h>

#import "ChemicalBurnConnection.h"
#import "ChemicalBurnNode.h"
#import "ChemicalBurnOrderedQueue.h"
#import "ChemicalBurnPackage.h"
#import "ChemicalBurnSafeQueue.h"

#if DEBUG
#define DEBUG_LOGGING 1
#endif

#if DEBUG_LOGGING
#define DEBUG_LOG( fmt, ... ) NSLog( fmt, ## __VA_ARGS__ )
#else
#define DEBUG_LOG( fmt, ... )
#endif

static const int kNodeChangeInterval = 45;
static const int kPackageGenerateInterval = 60;

@implementation ChemicalBurnView

- (id)initWithFrame: (NSRect)frame isPreview: (BOOL)isPreview
{
    self = [super initWithFrame: frame isPreview: isPreview];
    if( self )
	{
		mNodes = [[NSMutableArray alloc] init];
		mDestroyNodes = [[NSMutableArray alloc] init];
		mNodeConnectionDict = [[NSMutableDictionary alloc] init];
		mPackages = [[NSMutableSet alloc] init];
		
        [self setAnimationTimeInterval: 1/30.0];
		mNumRoutingThreads = [ChemicalBurnNode numRoutingThreads];

		[self setDefaultValues];
		[self loadFromUserDefaults];
		
#if DEBUG_LOGGING
		int fd = open("/tmp/cblog", O_WRONLY | O_CREAT | O_TRUNC | O_APPEND, 0777);
		dup2( fd, 2 );
		close( fd );
#endif
	}
    return self;
}

- (void)dealloc
{
	[mGLContext release];
	[mNodes release];
	[mDestroyNodes release];
	[mNodeConnectionDict release];
	[mPackages release];
	
	[mConfigurationWindow release];
	[mConfigurationObjectController release];
	
	[super dealloc];
}

- (BOOL)isOpaque
{
	return YES;
}

#pragma mark -

- (NSString *)printNodes
{
	NSMutableString *str = [NSMutableString string];
	int threadID = NodeGetThreadID( self );
	forall_array( n, mNodes )
	{
		[str appendFormat: @"%@ cost:%u prev:%@\n", n, NODE_COST( threadID, n ), NODE_PREV( threadID, n )];
	}
	return str;
}

- (ChemicalBurnConnection *)searchConnectionFrom: (ChemicalBurnNode *)src to: (ChemicalBurnNode *)dst
{
	int threadID = NodeGetThreadID( self );
	
	// initialize costs with infinity
	forall_array( n, mNodes )
		NODE_COST( threadID, n ) = 0xFFFFFFFF;
	// except for source
	NODE_COST( threadID, src ) = 0;
	
	NSMutableSet *hitNodes = [[NSMutableSet alloc] init];
	ChemicalBurnOrderedQueue *remainingNodes = [[ChemicalBurnOrderedQueue alloc] init];
	[remainingNodes addObject: src value: 0];
	
	while( [remainingNodes count] > 0 )
	{
		ChemicalBurnNode *bestNode = [remainingNodes pop];
		if( [hitNodes containsObject: bestNode] ) // skip stuff we've already seen
			continue;
		
		[hitNodes addObject: bestNode];
		
		unsigned bestCost = NODE_COST( threadID, bestNode );
		
		if( bestNode == dst )
			break;
		
		// follow all connections from the smallest node
		forall_array( c, [mNodeConnectionDict objectForKey: bestNode] )
		{
			// find the other node for the connection
			ChemicalBurnNode *otherN = [c otherNodeFor: bestNode];
			
			// calculate costs
			unsigned connCost = ChemicalBurnConnectionGetCost( (ChemicalBurnConnection *)c );
			unsigned curCost = NODE_COST( threadID, otherN );
			if( bestCost + connCost < curCost )
			{
				// this route is faster, so reset cost and prev of the other node
				NODE_COST( threadID, otherN ) = bestCost + connCost;
				NODE_PREV( threadID, otherN ) = bestNode;
				
				[remainingNodes addObject: otherN value: bestCost + connCost];
			}
		}
	}
	
	[hitNodes release];
	[remainingNodes release];
	
	// we found the fastest path, read it out of the prevs starting from the destination
	ChemicalBurnNode *n = nil;
	ChemicalBurnNode *prev = dst;
	while( prev != src )
	{
		if( prev == NULL )
			[NSException raise: NSInternalInconsistencyException format: @"%s: prev == NULL!", __func__];
		
		n = prev;
		prev = NODE_PREV( threadID, n );
	}
	
	// n now contains the first node to follow on the best path away from src
	// so find the connection that matches
	forall_array( c, [mNodeConnectionDict objectForKey: src] )
		if( [c containsNode: n] )
			return c;
	
	NSLog( @"%s: execution should never reach here, destination %@  nodes %@", __func__, dst, mNodes );
	return nil;
}

#pragma mark -

- (void)decayStats
{
	double factor = 0.99;
	mPackageSteps *= factor;
	mDeliveredPackages *= factor;
}

- (void)generateNodeAtPoint: (NSPoint)p
{
	ChemicalBurnNode *n = [[ChemicalBurnNode alloc] initWithPos: p];
	
	NSMutableArray *array = [NSMutableArray array];
	
	forall_array( on, mNodes )
	{
		ChemicalBurnConnection *c = [ChemicalBurnConnection connectionWithNode: n andNode: on];
		[array addObject: c];
		[[mNodeConnectionDict objectForKey: on] addObject: c];
	}
	forall_array( on, mDestroyNodes )
	{
		ChemicalBurnConnection *c = [ChemicalBurnConnection connectionWithNode: n andNode: on];
		[c setWillRemove];
		[array addObject: c];
		[[mNodeConnectionDict objectForKey: on] addObject: c];
	}
	
	[mNodeConnectionDict setObject: array forKey: n];
	
	[mNodes addObject: n];
	[n release];
}

- (void)generateNode
{
	NSPoint p = SSRandomPointForSizeWithinRect( NSZeroSize, [self bounds] );
	[self generateNodeAtPoint: p];
}

- (void)generateNodes
{
	int i;
	for( i = 0; i < mOptimalNodeCount; i++ )
	{
		[self generateNode];
	}
}

- (ChemicalBurnPackage *)generatePackageIsDeath: (BOOL)isDeath
{
	ChemicalBurnNode *source;
	ChemicalBurnConnection *conn;
	do {
		unsigned sourceIndex = SSRandomIntBetween( 0, [mNodes count] - 1 );
		source = [mNodes objectAtIndex: sourceIndex];
		
		NSArray *connections = [mNodeConnectionDict objectForKey: source];
		unsigned connectionIndex = SSRandomIntBetween( 0, [connections count] - 1 );
		conn = [connections objectAtIndex: connectionIndex];
	} while( [conn willRemove] );
	
	ChemicalBurnNode *destination = [conn otherNodeFor: source];
	ChemicalBurnPackage *pkg = [[ChemicalBurnPackage alloc] initWithSource: source
															   destination: destination
																 startStep: mStep];
	if( isDeath )
		[pkg setPackageOfDeath];
	
	[mPackages addObject: pkg];
	
	DEBUG_LOG( @"Generated %@ with destination %@", pkg, [pkg destination] );
	
	[pkg release];
	
	return pkg;
}

- (void)generatePackages
{
	unsigned count = [mNodes count];
	unsigned i;
	for( i = 0; i < count; i++ )
	{
		if( SSRandomIntBetween( 0, kPackageGenerateInterval - 1 ) == 0 )
		{
			[self generatePackageIsDeath: NO];
		}
	}
}

- (void)redirectPackage: (ChemicalBurnPackage *)p awayFromNode: (ChemicalBurnNode *)n
{
	ChemicalBurnNode *newDest;
	do {
		newDest = [mNodes objectAtIndex: SSRandomIntBetween( 0, [mNodes count] - 1 )];
	} while( newDest == n || newDest == [p curNode] );
	[p setDestination: newDest];
}

- (void)addNodeToDestroyList: (ChemicalBurnNode *)n
{
	DEBUG_LOG( @"adding %@ to destroy list", n );
	[mDestroyNodes addObject: n];
	[mNodes removeObject: n];
	
	forall_array( c, [mNodeConnectionDict objectForKey: n] )
		[c setWillRemove];
	
	forall_array( p, [mPackages allObjects] )
	{
		// redirect packages whose destination is here but
		// who aren't yet on a direct connection
		if( [p destination] == n )
		{
			if( [p curConnectionDestination] != n )
			{
				DEBUG_LOG( @"redirecting %@ away from %@", p, n );
				[self redirectPackage: p awayFromNode: n];
				DEBUG_LOG( @"%@ has new destination %@", p, [p destination] );
			}
			else
			{
				DEBUG_LOG( @"%@ is on %@<->%@ (forward=%@) and will not redirect away from %@", p, [[p curConnection] node1], [[p curConnection] node2], [p valueForKey: @"mForward"], n );
			}
		}
	}
}

- (void)stepPackages
{
	forall_array( p, [mPackages allObjects] )
	{
		ChemicalBurnNode *curNode = [p curNode];
		if( !curNode )
		{
			[p step];
		}
		else
		{
			if( [p isPackageOfDeath] && [mNodes count] > 3 )
			{
				[self addNodeToDestroyList: curNode];
				if( curNode == [p destination] )
					[self redirectPackage: p awayFromNode: curNode];
			}
			
			[[p curConnection] incrementWeight];
			
			ChemicalBurnNode *destination = [p destination];
			if( curNode == destination )
			{
				mPackageSteps += mStep - [p startStep];
				mDeliveredPackages++;
				
				[p setConnection: nil forward: NO];
				
				[mPackages removeObject: p];
			}
			else
				[mPackagesToRoute push: p];
		}
	}
	
	[mPackagesToRoute waitForCompletion];
	[mPackagesToRoute reset];
}

- (void)routingThread
{
	BOOL shouldStop = NO;
	while( !shouldStop )
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NSNull *nsnull = [NSNull null];
		
		id p = [mPackagesToRoute pop];
		BOOL isNull = p == nsnull;
		
		if( !isNull )
		{
			ChemicalBurnNode *curNode = [p curNode];
			ChemicalBurnConnection *nextConn = [self searchConnectionFrom: curNode
																	   to: [p destination]];
			[p setConnection: nextConn forward: [nextConn node1] == curNode];
		}
		
		[mPackagesToRoute completedItem: p];
		
		if( isNull )
			shouldStop = YES;
		
		[pool release];
	}
}

- (void)makeConnectionsPerformSelector: (SEL)sel
{
	forall_array( node, mNodes )
	{
		forall_array( conn, [mNodeConnectionDict objectForKey: node] )
		{
			if( [conn node1] == node )
				[conn performSelector: sel];
		}
	}
}

- (void)degradeConnections
{
	[self makeConnectionsPerformSelector: @selector( decrementWeight )];
}

- (BOOL)shouldDestroyNode
{
	int nodediff = [mNodes count] - mOptimalNodeCount;
	float factor = (nodediff <= 0 ? 1.0 : (float)(mOptimalNodeCount - nodediff) / (float)mOptimalNodeCount);
	factor = MAX( factor, 0.0 );
	return SSRandomIntBetween( 0, kNodeChangeInterval * factor ) == 0 && [mNodes count] > 3;
}

- (void)adjustPackageOfDeathSpeed
{
	float factor = (float)[mNodes count] / (float)mOptimalNodeCount;
	[mPackageOfDeath setSpeed: factor * factor];
}

- (void)randomAddNodeToDestroyList
{
	if( [self shouldDestroyNode] )
	{
		unsigned index = SSRandomIntBetween( 0, [mNodes count] - 1 );
		[self addNodeToDestroyList: [mNodes objectAtIndex: index]];
	}
}

- (void)randomGeneratePackageOfDeath
{
	if( [self shouldDestroyNode] )
		[self generatePackageIsDeath: YES];
}

- (void)scanNodeDestroyList
{
	if( [mDestroyNodes count] > 0 )
	{
		ChemicalBurnNode *deathNode = [mPackageOfDeath curNode];
		forall_array( n, [NSArray arrayWithArray: mDestroyNodes] )
		{
			if( deathNode == n )
				continue;
			
			NSMutableArray *connections = [mNodeConnectionDict objectForKey: n];
			BOOL connectionsHavePackages = NO;
			forall_array( c, connections )
			{
				if( [c hasPackages] )
				{
					connectionsHavePackages = YES;
					break;
				}
			}
			
			if( !connectionsHavePackages )
			{
				forall( c, connections )
				{
					ChemicalBurnNode *otherN = [c otherNodeFor: n];
					[[mNodeConnectionDict objectForKey: otherN] removeObject: c];
				}
				
				[mNodeConnectionDict removeObjectForKey: n];
				DEBUG_LOG( @"finalizing destruction of %@", n );
				[mDestroyNodes removeObject: n];
			}
		}
	}
}

- (void)destroyNodes
{
	if( mHasPackageOfDeath )
		[self adjustPackageOfDeathSpeed];
	else
		[self randomAddNodeToDestroyList];
	
	[self scanNodeDestroyList];
}

- (void)createNodes
{
	int nodediff = mOptimalNodeCount - [mNodes count];
	float factor = (nodediff <= 0 ? 1.0 : (float)(mOptimalNodeCount - nodediff) / (float)mOptimalNodeCount);
	if( SSRandomIntBetween( 0, kNodeChangeInterval * factor ) == 0 )
		[self generateNode];
}

#pragma mark -

- (void)setupGL
{
	NSOpenGLPixelFormatAttribute attribs[] = {
		NSOpenGLPFADoubleBuffer,
		0
	};
	NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
	mGLContext = [[NSOpenGLContext alloc] initWithFormat: format shareContext: nil];
	[format release];
	
	[mGLContext setView: self];
	
	[mGLContext makeCurrentContext];
	
	NSRect bounds = [self bounds];
	glViewport( 0, 0, NSWidth( bounds ), NSHeight( bounds ) );
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	gluOrtho2D( 0, NSWidth( bounds ), 0, NSHeight( bounds ) );
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
	
	glEnable( GL_LINE_SMOOTH );
	glEnable( GL_POLYGON_SMOOTH );
	glHint( GL_LINE_SMOOTH_HINT, GL_NICEST );
	glHint( GL_POLYGON_SMOOTH_HINT, GL_NICEST );
	glEnable( GL_BLEND );
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	
	glClearColor( 0, 0, 0, 1 );
	
	[NSOpenGLContext clearCurrentContext];
}	

#pragma mark -

- (void)startAnimation
{
    [super startAnimation];
    
	mStepTimer = [NSTimer scheduledTimerWithTimeInterval: 0 target: self selector: @selector( step ) userInfo: nil repeats: YES];
    
	[self generateNodes];
	if( mCreateDestroyNodes && mHasPackageOfDeath )
		mPackageOfDeath = [self generatePackageIsDeath: YES];
	
	mPackagesToRoute = [[ChemicalBurnSafeQueue alloc] init];
	
	int i;
	for( i = 0; i < mNumRoutingThreads; i++ )
		[NSThread detachNewThreadSelector: @selector( routingThread ) toTarget: self withObject: nil];
}

- (void)stopAnimation
{
    [super stopAnimation];
    
    [mStepTimer invalidate];
    mStepTimer = nil;
	
	[mNodes removeAllObjects];
	[mDestroyNodes removeAllObjects];
	[mNodeConnectionDict removeAllObjects];
	[mPackages removeAllObjects];
	mPackageOfDeath = nil;
	
	mStep = 0;
	mPackageSteps = 0;
	mDeliveredPackages = 0;
	
	int i;
	for( i = 0; i < mNumRoutingThreads; i++ )
		[mPackagesToRoute push: [NSNull null]];
	[mPackagesToRoute waitForCompletion];
	[mPackagesToRoute terminate];
	[mPackagesToRoute release];
	mPackagesToRoute = nil;
	
	NodeThreadIDCleanup( self );
}

- (void)drawRect: (NSRect)rect
{
	if( !mGLContext )
		[self setupGL];
	
	[mGLContext makeCurrentContext];
	glClear( GL_COLOR_BUFFER_BIT );
	
	glColor4f( 1, 1, 1, 1 );
	glBegin( GL_QUADS );
	[mNodes makeObjectsPerformSelector: @selector( drawGL )];
	glEnd();
	
	glColor4f( 0.5, 0, 0, 1 );
	glBegin( GL_QUADS );
	[mDestroyNodes makeObjectsPerformSelector: @selector( drawGL )];
	glEnd();
	
	[self makeConnectionsPerformSelector: @selector( drawGL )];
	
	[mPackages makeObjectsPerformSelector: @selector( drawGL )];
	
	[mGLContext flushBuffer];
	[NSOpenGLContext clearCurrentContext];
	
	/*
	[[NSColor blackColor] setFill];
	NSRectFill( rect );
	
	[mConnections makeObjectsPerformSelector: @selector( draw )];
	[mNodes makeObjectsPerformSelector: @selector( draw )];
	[mPackages makeObjectsPerformSelector: @selector( draw )];
	*/
	/*
	if( mDeliveredPackages > 0.1 )
	{
		[[NSString stringWithFormat: @"Steps per package: %.0f", mPackageSteps / mDeliveredPackages]
				drawAtPoint: NSZeroPoint
			 withAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
				 [NSColor whiteColor], NSForegroundColorAttributeName,
				 nil]];
	}
	 */
}

- (void)step
{
	[self decayStats];
	[self stepPackages];
	
	if( mCreateDestroyNodes )
	{
		[self destroyNodes];
		[self createNodes];
	}
	
	[self degradeConnections];
	[self generatePackages];
	
	mStep++;
}

- (void)animateOneFrame
{
	[self step];
	
	[self setNeedsDisplay: YES];
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (void)loadConfigurationNib
{
	[NSBundle loadNibNamed: @"ConfigurationPanel" owner: self];
	
	NSString *vers = [[NSBundle bundleForClass: [self class]] objectForInfoDictionaryKey: @"CFBundleVersion"];
	vers = [NSString stringWithFormat: @"version %@", vers];
	[mVersionField setStringValue: vers];
	
	NSUserDefaults *def = [ScreenSaverDefaults defaultsForModuleWithName: [[NSBundle bundleForClass: [self class]] bundleIdentifier]];
	NSUserDefaultsController *controller = [[NSUserDefaultsController alloc] initWithDefaults: def initialValues: nil];
	[mConfigurationObjectController setContent: controller];
	[controller release];
}

- (NSWindow*)configureSheet
{
	if( !mConfigurationWindow )
		[self loadConfigurationNib];
	
	return mConfigurationWindow;
}

- (IBAction)configurationCancel: (id)sender
{
	[[mConfigurationObjectController content] revert: sender];
	[NSApp endSheet: mConfigurationWindow];
}

- (IBAction)configurationOK: (id)sender
{
	[(NSUserDefaultsController *)[mConfigurationObjectController content] save: sender];
	[self loadFromUserDefaults];
	
	[NSApp endSheet: mConfigurationWindow];
	
	[self stopAnimation];
	[self startAnimation];
}

- (IBAction)configurationHelp: (id)sender
{
	NSString *path = [[NSBundle bundleForClass: [self class]] pathForResource: @"index" ofType: @"html" inDirectory: @"help"];
	[[NSWorkspace sharedWorkspace] openFile: path];
}

- (IBAction)configurationAbout: (id)sender
{
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://www.mikeash.com/"]];
}

- (void)setDefaultValues
{
	NSUserDefaults *def = [ScreenSaverDefaults defaultsForModuleWithName: [[NSBundle bundleForClass: [self class]] bundleIdentifier]];
	[def registerDefaults:
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: kConnectionWeightSqrt], @"trafficWeight",
			[NSNumber numberWithInt: kConnectionWeightLinear], @"distanceWeight",
			[NSNumber numberWithInt: 100], @"numNodes",
			[NSNumber numberWithBool: YES], @"createDestroyNodes",
			[NSNumber numberWithBool: YES], @"packageOfDeath",
			nil]];
}

- (void)loadFromUserDefaults
{
	NSUserDefaults *def = [ScreenSaverDefaults defaultsForModuleWithName: [[NSBundle bundleForClass: [self class]] bundleIdentifier]];
	mOptimalNodeCount = [def integerForKey: @"numNodes"];
	mCreateDestroyNodes = [def boolForKey: @"createDestroyNodes"];
	mHasPackageOfDeath = [def boolForKey: @"packageOfDeath"];
	
	[ChemicalBurnConnection setCurve: [def integerForKey: @"trafficWeight"] forWeight: kConnectionTrafficWeight];
	[ChemicalBurnConnection setCurve: [def integerForKey: @"distanceWeight"] forWeight: kConnectionDistanceWeight];
}

@end
