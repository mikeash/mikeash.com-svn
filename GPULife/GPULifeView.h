//
//  GPULifeView.h
//  GPULife
//
//  Created by Michael Ash on 5/12/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <OpenGL/gl.h>


typedef struct {
	float r, g, b;
} GPULifeColor3;

@interface GPULifeView : NSOpenGLView {
	BOOL inited;
	GLuint tex;
	GLuint shader;
	int xsize, ysize;
	
	BOOL usingFPSTex;
	GLuint fpsTex;
	int fpsTexXSize, fpsTexYSize;
	
	int zoom;
	
	int generationRate;
	int initialFill;

	int numFrames;
	double lastClock;
	
	GPULifeColor3 cornerColors[4];
	
	id fpsTarget;
	SEL fpsSelector;
	
	BOOL usesTimer;
}

- (void)setZoom:(int)z;
- (void)setGenerationRate:(int)r;
- (void)setInitialFill:(int)f;
- (void)setCornerColors:(GPULifeColor3 *)c;
- (void)setFPSTarget:o selector:(SEL)s;
- (void)setShowsFPS:(BOOL)yorn;
- (void)setUsesTimer:(BOOL)yorn;

@end
