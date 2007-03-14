//
//  GPULifeSaverView.h
//  GPULife
//
//  Created by Michael Ash on 5/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaver.h>


@class GPULifeView;

@interface GPULifeSaverView : ScreenSaverView {
	GPULifeView *lifeView;
	
	IBOutlet NSWindow *configureSheet;
	IBOutlet NSButton *limitFPSCheckbox;
	IBOutlet NSSlider *fpsSlider;
	IBOutlet NSButton *displayFPSCheckbox;
	IBOutlet NSTextField *fpsField;
	IBOutlet NSSlider *zoomSlider;
	IBOutlet NSTextField *zoomField;
	IBOutlet NSSlider *initialFillSlider;
	IBOutlet NSTextField *generationField;
	
	IBOutlet NSBox *colorWellBox;
	NSDictionary *colorWells;
	
	NSString *fpsString;
}

- (void)limitFPSChecked:sender;
- (void)limitFPSSlider:sender;
- (void)limitFPSField:sender;
- (void)ok:sender;
- (void)cancel:sender;

@end
