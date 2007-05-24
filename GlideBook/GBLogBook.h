//
//  GBLogBook.h
//  GlideBook
//
//  Created by Michael Ash on 4/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


extern NSString * const GBLogBookDidChangeNotification;

@interface GBLogBook : NSObject
{
	NSMutableArray*		mEntries;
}

- (id)initWithData: (NSData *)data error: (NSError **)outError;

- (NSData *)data;

- (NSMutableArray *)entries;

@end
