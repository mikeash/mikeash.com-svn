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

- (BOOL)matches: (NSDictionary *)dict
{
	if( !mString || [mString isEqualToString: @""] )
		return YES;
	
	NSEnumerator *enumerator = [dict keyEnumerator];
	id key;
	while( (key = [enumerator nextObject]) )
	{
		id obj = [dict objectForKey: key];
		if( [obj isKindOfClass: [NSString class]] )
		{
			if( [obj rangeOfString: mString].location != NSNotFound )
				return YES;
		}
	}
	
	return NO;
}

- (NSArray *)filterArray: (NSArray *)array
{
	NSMutableArray *ret = [NSMutableArray array];
	forall( obj, array )
		if( [self matches: obj] )
			[ret addObject: obj];
	return ret;
}

@end
