//
//  GBFilter.m
//  GlideBook
//
//  Created by Michael Ash on 5/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GBFilter.h"


@implementation GBFilter

+ (id)filterWithString: (NSString *)string
{
	return [[self alloc] initWithString: string];
}

- (id)initWithString: (NSString *)string
{
	if( (self = [self init]) )
	{
		mString = [string copy];
	}
	return self;
}

- (BOOL)evaluateWithObject: (id)object
{
	if( !mString || [mString isEqualToString: @""] )
		return YES;
	
	NSEnumerator *enumerator = [object keyEnumerator];
	id key;
	while( (key = [enumerator nextObject]) )
	{
		id obj = [object objectForKey: key];
		if( [obj isKindOfClass: [NSString class]] )
		{
			if( [obj rangeOfString: mString].location != NSNotFound )
				return YES;
		}
	}
	
	return NO;
}

@end
