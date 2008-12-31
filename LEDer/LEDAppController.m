//
//  LEDAppController.m
//  LEDer
//
//  Created by Michael Ash on 12/31/08.
//  Copyright 2008 Rogue Amoeba Software, LLC. All rights reserved.
//

#import "LEDAppController.h"

#import "keyboard_leds.h"


@interface LEDAppController ()

- (void)_scheduleIntervalTimer;
- (unsigned)_getCount;

@end

@implementation LEDAppController

- (id)init
{
	if( (self = [super init]) )
	{
		_mailApp = [SBApplication applicationWithBundleIdentifier: @"com.apple.Mail"];
	}
	return self;
}

- (void)applicationDidFinishLaunching: (NSNotification *)note
{
	[self _scheduleIntervalTimer];
}

- (void)applicationWillTerminate: (NSNotification *)note
{
	manipulate_led( kHIDUsage_LED_CapsLock, 0 );
}

- (void)_scheduleIntervalTimer
{
	[NSTimer scheduledTimerWithTimeInterval: 1.0
									 target: self
								   selector: @selector( _scheduleBlinkTimer )
								   userInfo: nil
									repeats: NO];
}

- (void)_scheduleBlinkTimer
{
	_counter = [self _getCount] * 2;
	[NSTimer scheduledTimerWithTimeInterval: 0.1
									 target: self
								   selector: @selector( _blink: )
								   userInfo: nil
									repeats: YES];
}

- (void)_blink: (NSTimer *)timer
{
	if( !_counter )
	{
		[timer invalidate];
		[self _scheduleIntervalTimer];
	}
	else
	{
		_counter--;
		manipulate_led( kHIDUsage_LED_CapsLock, _counter % 2 );
	}
}

- (unsigned)_getCount
{
	@try
	{
		if( [_mailApp isRunning] )
			return [[_mailApp inbox] unreadCount];
	}
	@catch( id exception )
	{
		NSLog( @"%@", exception );
	}
	return 0;
}

@end
