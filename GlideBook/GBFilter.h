//
//  GBFilter.h
//  GlideBook
//
//  Created by Michael Ash on 5/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GBFilter : NSObject
{
	NSString*	mString;
}

+ (id)filterWithString: (NSString *)string;

- (id)initWithString: (NSString *)string;

- (BOOL)matches: (NSDictionary *)dict;
- (NSArray *)filterArray: (NSArray *)array;

@end
