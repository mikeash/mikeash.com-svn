//
//  DiagonalSliderAppDelegate.m
//  DiagonalSlider
//
//  Created by Michael Ash on 4/21/10.
//  Copyright 2010 Rogue Amoeba Software, LLC. All rights reserved.
//

#import "DiagonalSliderAppDelegate.h"

@implementation DiagonalSliderAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

- (IBAction)sliderMoved: (id)sender
{
    NSLog(@"Slider moved to value %f", [sender doubleValue]);
}

@end
