//
//  GPULifeSaverView.m
//  GPULife
//
//  Created by Michael Ash on 5/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "GPULifeSaverView.h"

#import "GPULifeView.h"


@implementation GPULifeSaverView

static NSString * const kLimitFPSDefaultsName = @"LimitFPS";
static NSString * const kLimitFPSValueDefaultsName = @"LimitFPSValue";
static NSString * const kDisplayFPSDefaultsName = @"DisplayFPS";
static NSString * const kZoomDefaultsName = @"Zoom";
static NSString * const kInitialFillDefaultsName = @"InitialFill";
static NSString * const kGenerationDefaultsName = @"GenerationRate";
static NSString * const kCornerColorsDefaultsName = @"CornerColors";

+ (void)initialize
{
	[[ScreenSaverDefaults defaultsForModuleWithName:
		[[NSBundle bundleForClass:[self class]] bundleIdentifier]] registerDefaults:
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:YES], kLimitFPSDefaultsName,
			[NSNumber numberWithDouble:30.0], kLimitFPSValueDefaultsName,
			[NSNumber numberWithBool:NO], kDisplayFPSDefaultsName,
			[NSNumber numberWithInt:2], kZoomDefaultsName,
			[NSNumber numberWithInt:12], kInitialFillDefaultsName,
			[NSNumber numberWithInt:1], kGenerationDefaultsName,
			[NSArchiver archivedDataWithRootObject:[NSArray arrayWithObjects:
				[NSColor redColor], [NSColor blueColor], [NSColor greenColor], [NSColor whiteColor], nil]],
			kCornerColorsDefaultsName,
			nil]];
}

- (GPULifeColor3)structForNSColor:(NSColor *)c
{
	GPULifeColor3 ret;
	c = [c colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	[c getRed:&ret.r green:&ret.g blue:&ret.b alpha:NULL];
	float max = MAX(MAX(ret.r, ret.g), ret.b);
	
	// make sure the color isn't too black so the shader can still find it
	if(max < 0.101)
	{
		if(max == 0.0)
			ret.r = ret.g = ret.b = 0.101;
		else
		{
			ret.r *= 0.101 / max;
			ret.g *= 0.101 / max;
			ret.b *= 0.101 / max;
		}
	}
	return ret;
}

- (void)reinitLifeView
{
	[lifeView removeFromSuperview];
	[lifeView release];
	
	lifeView = [[GPULifeView alloc] initWithFrame:[self bounds]];
	[lifeView setUsesTimer:NO];
		
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:
		[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
	[lifeView setShowsFPS:[defaults boolForKey:kDisplayFPSDefaultsName]];
	[lifeView setZoom:[defaults integerForKey:kZoomDefaultsName]];
	[lifeView setGenerationRate:[defaults integerForKey:kGenerationDefaultsName]];
	[lifeView setInitialFill:[defaults integerForKey:kInitialFillDefaultsName]];
	
	GPULifeColor3 colorsArray[4];
	NSArray *colors = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:kCornerColorsDefaultsName]];
	int i;
	for(i = 0; i < 4; i++)
		colorsArray[i] = [self structForNSColor:[colors objectAtIndex:i]];
	[lifeView setCornerColors:colorsArray];
	
	[self addSubview:lifeView];
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		[self reinitLifeView];
    }
    return self;
}

- (void)dealloc
{
	[lifeView release];
	[colorWells release];
	[configureSheet release];
	[super dealloc];
}

- (void)startAnimation
{
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:
		[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
	if([defaults boolForKey:kLimitFPSDefaultsName])
		[self setAnimationTimeInterval:1.0 / [[defaults objectForKey:kLimitFPSValueDefaultsName] doubleValue]];
	else
		[self setAnimationTimeInterval:0.0];
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
}

- (void)animateOneFrame
{
	[lifeView display];
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (void)fillDictionary:(NSMutableDictionary*)dict withColorWellsInView:(NSView *)superview
{
	NSEnumerator *enumerator = [[superview subviews] objectEnumerator];
	NSView *view;
	while((view = [enumerator nextObject]))
	{
		if([view isKindOfClass:[NSColorWell class]])
			[dict setObject:view forKey:[NSNumber numberWithInt:[view tag]]];
		else
			[self fillDictionary:dict withColorWellsInView:view];
	}
}

- (NSWindow*)configureSheet
{
	if(!configureSheet)
	{
		[NSBundle loadNibNamed:@"ScreenSaver" owner:self];
		
		NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
		[self fillDictionary:tempDict withColorWellsInView:colorWellBox];
		[colorWells release];
		colorWells = [tempDict copy];
	}
	
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
	
	[limitFPSCheckbox setState:[defaults boolForKey:kLimitFPSDefaultsName] ? NSOnState : NSOffState];
	double fpsLimit = [[defaults objectForKey:kLimitFPSValueDefaultsName] doubleValue];;
	[fpsSlider setDoubleValue:fpsLimit];
	[fpsField setDoubleValue:fpsLimit];
	[displayFPSCheckbox setState:[defaults boolForKey:kDisplayFPSDefaultsName] ? NSOnState : NSOffState];
	int zoom = [defaults integerForKey:kZoomDefaultsName];
	[zoomSlider setIntValue:zoom];
	[zoomField setIntValue:zoom];
	[initialFillSlider setIntValue:[defaults integerForKey:kInitialFillDefaultsName]];
	[generationField setIntValue:[defaults integerForKey:kGenerationDefaultsName]];
	
	NSArray *colors = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:kCornerColorsDefaultsName]];
	int i;
	for(i = 0; i < 4; i++)
		[[colorWells objectForKey:[NSNumber numberWithInt:i]] setColor:[colors objectAtIndex:i]];
	
	[self limitFPSChecked:limitFPSCheckbox];
	
    return configureSheet;
}

- (void)limitFPSChecked:sender
{
	[fpsSlider setEnabled:[sender state] == NSOnState];
	[fpsField setEnabled:[sender state] == NSOnState];
}

- (void)limitFPSSlider:sender
{
	double fpsLimit = [fpsSlider doubleValue];
	[fpsField setDoubleValue:fpsLimit];
}

- (void)limitFPSField:sender
{
	double fpsLimit = [fpsField doubleValue];
	[fpsSlider setDoubleValue:fpsLimit];
}

- (void)ok:sender
{
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
	
	[defaults setBool:[limitFPSCheckbox state] == NSOnState forKey:kLimitFPSDefaultsName];
	[defaults setObject:[NSNumber numberWithDouble:[fpsField doubleValue]] forKey:kLimitFPSValueDefaultsName];
	[defaults setBool:[displayFPSCheckbox state] == NSOnState forKey:kDisplayFPSDefaultsName];
	[defaults setInteger:[zoomField intValue] forKey:kZoomDefaultsName];
	[defaults setInteger:[initialFillSlider intValue] forKey:kInitialFillDefaultsName];
	[defaults setInteger:[generationField intValue] forKey:kGenerationDefaultsName];
	
	NSMutableArray *array = [NSMutableArray array];
	int i;
	for(i = 0; i < 4; i++)
		[array addObject:[[colorWells objectForKey:[NSNumber numberWithInt:i]] color]];
	[defaults setObject:[NSArchiver archivedDataWithRootObject:array] forKey:kCornerColorsDefaultsName];
	
	[defaults synchronize];
	
	[NSApp endSheet:configureSheet];
	
	[self reinitLifeView];
	
	[[NSColorPanel sharedColorPanel] orderOut:nil];
}

- (void)cancel:sender
{
	[NSApp endSheet:configureSheet];
	
	[[NSColorPanel sharedColorPanel] orderOut:nil];
}

@end
