//
//  LEDAppController.h
//  LEDer
//
//  Created by Michael Ash on 12/31/08.
//  Copyright 2008 Michael Ash. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MailScripting.h"


@interface LEDAppController : NSObject
{
	MailScriptingApplication *_mailApp;
	unsigned _counter;
}

@end
