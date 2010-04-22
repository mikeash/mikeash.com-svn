//
//  DiagonalSlider.h
//  DiagonalSlider
//
//  Created by Michael Ash on 4/21/10.
//  Copyright 2010 Rogue Amoeba Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DiagonalSlider : NSControl
{
    double _value;
    id _target;
    SEL _action;
}

- (void)setDoubleValue: (double)value;
- (double)doubleValue;

@end
