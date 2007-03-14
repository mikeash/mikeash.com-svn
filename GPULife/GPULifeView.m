//
//  GPULifeView.m
//  GPULife
//
//  Created by Michael Ash on 5/12/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "GPULifeView.h"

#include <OpenGL/gl.h>
#include <OpenGL/glext.h>
#include <OpenGL/glu.h>

#include <mach/mach_time.h>


@implementation GPULifeView

+ (void)initialize
{
	srandomdev();
}

- (id)initWithFrame:(NSRect)frame {
	NSOpenGLPixelFormatAttribute attribs[] = {
		NSOpenGLPFADoubleBuffer,
		0
	};
	NSOpenGLPixelFormat *myFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
    self = [super initWithFrame:frame pixelFormat:myFormat];
	[myFormat release];
    if (self)
	{
		zoom = 1;
		generationRate = 1;
		initialFill = 12;
		usesTimer = YES;
		
		GPULifeColor3 initialColors[4] = {
			{0, 0, 1},
			{0, 1, 0},
			{1, 0, 0},
			{0, 1, 1}
		};
		[self setCornerColors:initialColors];
    }
    return self;
}

- (void)dealloc
{
	glDeleteTextures(1, &tex);
	glDeleteProgramsARB(1, &shader);
	if(usingFPSTex)
		glDeleteTextures(1, &fpsTex);
	
	[super dealloc];
}

- (void)setZoom:(int)z
{
	if(inited)
	{
		NSLog(@"%s can only be called before the the view's first display", __func__);
		return;
	}
	zoom = z;
}

- (void)setGenerationRate:(int)r
{
	generationRate = r;
}

- (void)setInitialFill:(int)f
{
	if(inited)
	{
		NSLog(@"%s can only be called before the the view's first display", __func__);
		return;
	}
	initialFill = f;
}

- (void)setCornerColors:(GPULifeColor3 *)c
{
	memcpy(cornerColors, c, sizeof(cornerColors));
}

- (void)setFPSTarget:o selector:(SEL)s;
{
	if([o respondsToSelector:s])
	{
		fpsTarget = o;
		fpsSelector = s;
	}
	else
	{
		fpsTarget = nil;
		fpsSelector = NULL;
	}
}

- (void)setShowsFPS:(BOOL)yorn
{
	if(yorn)
		[self setFPSTarget:self selector:@selector(setFPSTextureWithString:)];
	else
	{
		[self setFPSTarget:nil selector:NULL];
		if(usingFPSTex)
		{
			glDeleteTextures(1, &fpsTex);
			usingFPSTex = NO;
		}
	}
}

- (void)setUsesTimer:(BOOL)yorn
{
	if(inited)
	{
		NSLog(@"%s can only be called before the the view's first display", __func__);
		return;
	}
	usesTimer = yorn;
}

- (void)createTexture
{
	uint32_t *data = malloc(xsize * ysize * sizeof(*data));
	int i;
	for(i = 0; i < xsize * ysize; i++)
		data[i] = (random() % 100) >= initialFill ? 0 : 0xFFFFFFFFUL;
	
	glGenTextures(1, &tex);
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, tex);
	glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_WRAP_T, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, xsize);
	glTexImage2D(GL_TEXTURE_RECTANGLE_ARB,
				 0,
				 GL_RGBA,
				 xsize,
				 ysize,
				 0,
				 GL_BGRA,
				 GL_UNSIGNED_INT_8_8_8_8_REV,
				 data);
	free(data);
}

- (void)loadShader
{
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"LifeShader" ofType:@""];
	NSString *source = [NSString stringWithContentsOfFile:path];
	const char *sourceC = [source UTF8String];
	
	glGenProgramsARB(1, &shader);
	glBindProgramARB(GL_FRAGMENT_PROGRAM_ARB, shader);
	glProgramStringARB(GL_FRAGMENT_PROGRAM_ARB, GL_PROGRAM_FORMAT_ASCII_ARB, strlen(sourceC), sourceC);
	glDisable(GL_FRAGMENT_PROGRAM_ARB);
}

- (void)reshape
{
	if(!inited)
	{
		xsize = [self bounds].size.width / zoom;
		ysize = [self bounds].size.height / zoom;
		[self createTexture];
		[self loadShader];
		inited = YES;
		
		if(usesTimer)
			[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(timer) userInfo:NULL repeats:YES];
	}
	
	
	/* select clearing color 	*/
	glClearColor (0.0, 0.0, 0.0, 1.0);
	glClear (GL_COLOR_BUFFER_BIT);
	
	/* initialize viewing values  */
	double w = NSWidth([self bounds]);
	double h = NSHeight([self bounds]);
	glViewport(0, 0, (GLsizei) w, (GLsizei) h);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluOrtho2D(0.0, (GLdouble) w, 0.0, (GLdouble) h);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	/*
	glEnable (GL_BLEND);
	
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glEnable(GL_TEXTURE_2D);
	 */
	//glEnable(GL_TEXTURE_RECTANGLE_EXT);
}

- (void)timer
{
	[self setNeedsDisplay:YES];
}

double curTime(void)
{
    static struct mach_timebase_info timebase;
    int timebaseInited = 0;
    if(!timebaseInited)
    {
        timebaseInited = 1;
        mach_timebase_info(&timebase);
    }
    return (double)((mach_absolute_time() * timebase.numer) / timebase.denom) / 1000.0;
}

- (void)setFPSTextureWithString:(NSString *)str
{
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSColor whiteColor], NSForegroundColorAttributeName,
		[NSFont userFixedPitchFontOfSize:16], NSFontAttributeName,
		nil];
	NSSize size = [str sizeWithAttributes:attrs];
	NSRect rect = NSMakeRect(0, 0, size.width, size.height);
	NSImage *image = [[NSImage alloc] initWithSize:size];
	[image lockFocus];
	[str drawInRect:rect withAttributes:attrs];
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:rect];
	[image unlockFocus];
	[image release];
	
	int bytesPerRow = [imageRep bytesPerRow];
	int bitsPerPixel = [imageRep bitsPerPixel];
	BOOL hasAlpha = [imageRep hasAlpha];
	void *data = [imageRep bitmapData];
	
	if(usingFPSTex)
		glDeleteTextures(1, &fpsTex);
	
	glGenTextures(1, &fpsTex);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, fpsTex);
	glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_T, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, bytesPerRow / (bitsPerPixel >> 3));
	glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 
				 0, 
				 GL_RGBA, 
				 size.width, 
				 size.height, 
				 0, 
				 hasAlpha ? GL_RGBA : GL_RGB, 
				 GL_UNSIGNED_BYTE, 
				 data);
	usingFPSTex = YES;
	fpsTexXSize = size.width;
	fpsTexYSize = size.height;
	
	[imageRep release];
}

- (void)measureFPS
{
	const int framesToMeasure = 50;
	
	numFrames++;
	if(lastClock == 0)
	{
		numFrames--;
		lastClock = curTime();
	}
	else if(numFrames >= framesToMeasure)
	{
		double now = curTime();
		double totalTime = now - lastClock;
		float floatTime = (float)totalTime / 1000000.0;
		float fps = (float)numFrames/floatTime;
		numFrames = 0;
		lastClock = now;
		[fpsTarget performSelector:fpsSelector withObject:[NSString stringWithFormat:@"fps = %.2f", fps]];
	}
}

- (void)drawTexture
{
	glBegin(GL_QUADS);
	
	glMultiTexCoord2fARB(GL_TEXTURE0_ARB, 0, 0);
	glMultiTexCoord3fARB(GL_TEXTURE1_ARB, cornerColors[0].r, cornerColors[0].g, cornerColors[0].b);
	glVertex2f(0, 0);
	
	glMultiTexCoord2fARB(GL_TEXTURE0_ARB, 0, ysize);
	glMultiTexCoord3fARB(GL_TEXTURE1_ARB, cornerColors[1].r, cornerColors[1].g, cornerColors[1].b);
	glVertex2f(0, ysize);
	
	glMultiTexCoord2fARB(GL_TEXTURE0_ARB, xsize, ysize);
	glMultiTexCoord3fARB(GL_TEXTURE1_ARB, cornerColors[2].r, cornerColors[2].g, cornerColors[2].b);
	glVertex2f(xsize, ysize);
	
	glMultiTexCoord2fARB(GL_TEXTURE0_ARB, xsize, 0);
	glMultiTexCoord3fARB(GL_TEXTURE1_ARB, cornerColors[3].r, cornerColors[3].g, cornerColors[3].b);
	glVertex2f(xsize, 0);
	
	glEnd();
}

- (void)step
{
	glActiveTextureARB(GL_TEXTURE0_ARB);
	glEnable(GL_TEXTURE_RECTANGLE_ARB);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, tex);
	glEnable(GL_FRAGMENT_PROGRAM_ARB);
	glBindProgramARB(GL_FRAGMENT_PROGRAM_ARB, shader);
	
	[self drawTexture];
	
	glDisable(GL_TEXTURE_RECTANGLE_ARB);
	glDisable(GL_FRAGMENT_PROGRAM_ARB);
	
	// plot some random pixels
	int i;
	glBegin(GL_QUADS);
	for(i = 0; i < generationRate; i++)
	{
		int x = random() % xsize;
		int y = random() % ysize;
		
		
		glColor4f(1.0, 1.0, 1.0, 1.0);
		glVertex2f(x, y);
		glVertex2f(x, y + 1);
		glVertex2f(x + 1, y + 1);
		glVertex2f(x + 1, y);
	}
	glEnd();
	
	glReadBuffer(GL_BACK);
	glCopyTexSubImage2D(GL_TEXTURE_RECTANGLE_ARB,
						0,
						0,
						0,
						0,
						0,
						xsize,
						ysize);
}

- (void)drawRect:(NSRect)rect {
	[self step];
	
	if(zoom != 1)
	{
		glEnable(GL_TEXTURE_RECTANGLE_ARB);
		glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, tex);
		
		glPushMatrix();
		
		glScalef(zoom, zoom, 1);
		[self drawTexture];
		
		glPopMatrix();
		
		glDisable(GL_TEXTURE_RECTANGLE_ARB);
	}
	
	if(usingFPSTex)
	{
		glEnable(GL_TEXTURE_RECTANGLE_EXT);
		glEnable(GL_BLEND);
		glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
		glBindTexture(GL_TEXTURE_RECTANGLE_EXT, fpsTex);
		
		glPushMatrix();
		glTranslatef(5, 5, 0);
		
		//glColor4f(0.0, 0.0, 0.0, 0.0);
		
		glBegin(GL_QUADS);
		
		glTexCoord2i(0, fpsTexYSize);
		glVertex2i(0, 0);
		
		glTexCoord2i(0, 0);
		glVertex2i(0, fpsTexYSize);
		
		glTexCoord2i(fpsTexXSize, 0);
		glVertex2i(fpsTexXSize, fpsTexYSize);
		
		glTexCoord2i(fpsTexXSize, fpsTexYSize);
		glVertex2i(fpsTexXSize, 0);
		
		glEnd();
		
		glPopMatrix();
		
		glDisable(GL_BLEND);
		glDisable(GL_TEXTURE_RECTANGLE_EXT);
	}
	
	[[self openGLContext] flushBuffer];
	
	if(fpsTarget)
		[self measureFPS];
}

@end
