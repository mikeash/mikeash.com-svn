//
//  DGController.h
//  DefGrowl
//
//  Created by Michael Ash on 8/30/07.
//  Copyright 2007 Rogue Amoeba Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>


@interface DGController : NSObject
{
	GLuint				_currentTexture;
	NSMutableSet*		_textTextures;
	unsigned			_captureCoordCount;
	
	NSMutableString*	_accumStr;
}

@end
