//
//  GBLogBook.m
//  GlideBook
//
//  Created by Michael Ash on 4/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GBLogBook.h"


NSString * const GBLogBookDidChangeNotification = @"GBLogBookDidChangeNotification";

@implementation GBLogBook

- (id)init
{
	if( (self = [super init]) )
	{
		mEntries = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithData: (NSData *)data error: (NSError **)outError
{
	if( (self = [self init]) )
	{
		NSString *errorString = nil;
		
		[mEntries release];
		NSDictionary *dict = [[NSPropertyListSerialization propertyListFromData: data
															   mutabilityOption: NSPropertyListMutableContainers
																		 format: NULL
															   errorDescription: &errorString] retain];
		if( dict )
			errorString = nil;
		
		mEntries = [[dict objectForKey: @"entries"] retain];
		
		if( !mEntries || ![mEntries isKindOfClass: [NSMutableArray class]] )
		{
			if( outError )
			{
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					errorString, NSLocalizedDescriptionKey,
					nil];
				*outError = [NSError errorWithDomain: NSCocoaErrorDomain code: 0 userInfo: userInfo];
				[errorString release];
			}
			[self release];
			self = nil;
		}
	}
	return self;
}

- (void)dealloc
{
	[mEntries release];
	[super dealloc];
}

- (NSData *)data
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
		mEntries, @"entries",
		nil];
	return [NSPropertyListSerialization dataFromPropertyList: dict format: NSPropertyListXMLFormat_v1_0 errorDescription: NULL];
}

- (NSMutableArray *)entries
{
	return mEntries;
}

@end
