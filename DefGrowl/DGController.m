//
//  DGController.m
//  DefGrowl
//
//  Created by Michael Ash on 8/30/07.
//  Copyright 2007 Rogue Amoeba Software, LLC. All rights reserved.
//

#import "DGController.h"

#import <OpenGL/glu.h>

#import "APELite.h"


@implementation DGController

static DGController *gController;

static void (*DG_glBindTexture_old)( GLenum target, GLuint texture );
static void DG_glBindTexture( GLenum target, GLuint texture );

GLint (*DG_gluBuild2DMipmaps_old)( GLenum target,
								   GLint internalFormat, GLsizei width,
								   GLsizei height,
								   GLenum format,
								   GLenum type,
								   const void *data );
static GLint DG_gluBuild2DMipmaps( GLenum target,
								   GLint internalFormat, GLsizei width,
								   GLsizei height,
								   GLenum format,
								   GLenum type,
								   const void *data );

static BOOL gCaptureTexture;
static void (*DG_glTexCoord2f_old)( GLfloat s, GLfloat t );
static void DG_glTexCoord2f( GLfloat s, GLfloat t );

static void (*DG_NSOpenGLContext_flushBuffer_old)( id self, SEL _cmd );
static void DG_NSOpenGLContext_flushBuffer( id self, SEL _cmd );

+ (void)load
{
	NSLog( @"DefGrowl: Hello world!" );
	
	gController = [[DGController alloc] init];
	
	DG_glBindTexture_old = APEPatchCreate( glBindTexture, DG_glBindTexture );
	DG_gluBuild2DMipmaps_old = APEPatchCreate( gluBuild2DMipmaps, DG_gluBuild2DMipmaps );
	DG_glTexCoord2f_old = APEPatchCreate( glTexCoord2f, DG_glTexCoord2f );
	DG_NSOpenGLContext_flushBuffer_old = APEPatchCreate( [NSOpenGLContext instanceMethodForSelector: @selector( flushBuffer )], DG_NSOpenGLContext_flushBuffer );
}

- (id)init
{
	if( (self = [super init]) )
	{
		_textTextures = [[NSMutableSet alloc] init];
		_accumStr = [[NSMutableString alloc] init];
	}
	return self;
}

static void DG_glBindTexture( GLenum target, GLuint texture )
{
	gController->_currentTexture = texture;
	gCaptureTexture = [gController->_textTextures containsObject: [NSNumber numberWithUnsignedInt: texture]];
	if( gCaptureTexture )
		gController->_captureCoordCount = 0;
	
	DG_glBindTexture_old( target, texture );
}

static GLint DG_gluBuild2DMipmaps( GLenum target,
								   GLint internalFormat, GLsizei width,
								   GLsizei height,
								   GLenum format,
								   GLenum type,
								   const void *data )
{
	NSNumber *texNum = [NSNumber numberWithUnsignedInt: gController->_currentTexture];
	if( width == 1024 && height == 1024 )
	{
		[gController->_textTextures addObject: texNum];
		gCaptureTexture = YES;
	}
	else
	{
		[gController->_textTextures removeObject: texNum];
		gCaptureTexture = NO;
	}
	
	NSLog( @"Text textures are %@", gController->_textTextures );
	
	return DG_gluBuild2DMipmaps_old( target, internalFormat, width, height, format, type, data );
}

static void DG_glTexCoord2f( GLfloat s, GLfloat t )
{
	if( gCaptureTexture )
	{
		if( gController->_captureCoordCount++ % 4 == 0 )
		{
			int x = rintf( s * 16.0 );
			int y = 16 - rintf( t * 16.0 );
			
			unichar ch = x + y * 16;
			[gController->_accumStr appendFormat: @"%C", ch];
		}
	}
	
	DG_glTexCoord2f_old( s, t );
}

static void DG_NSOpenGLContext_flushBuffer( id self, SEL _cmd )
{
	DG_NSOpenGLContext_flushBuffer_old( self, _cmd );
	NSLog( @"%@", gController->_accumStr );
	[gController->_accumStr setString: @""];
}

@end
