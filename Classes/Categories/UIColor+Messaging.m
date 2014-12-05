//
//  UIColor+Messaging.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-09-18.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "UIColor+Messaging.h"

@implementation UIColor (Messaging)

#pragma mark - iMessage

+ (UIColor *)iMessageGrayColor {
    return [UIColor colorWithRed:240 / 255.0
                           green:240 / 255.0
                            blue:240 / 255.0
                           alpha:1.0];
}

+ (UIColor *)iMessageBlueColor
{
    return [UIColor colorWithRed:0 / 255.0
                           green:122 / 255.0
                            blue:255 / 255.0
                           alpha:1.0];
}

+ (UIColor *)iMessageGreenColor
{
    return [UIColor colorWithRed:76 / 255.0
                           green:215 / 255.0
                            blue:100 / 255.0
                           alpha:1.0];
}

- (UIColor *)colorByDarkeningColorWithValue:(CGFloat)value
{
    NSUInteger totalComponents = CGColorGetNumberOfComponents(self.CGColor);
    BOOL isGreyscale = (totalComponents == 2) ? YES : NO;
    
    CGFloat *oldComponents = (CGFloat *)CGColorGetComponents(self.CGColor);
    CGFloat newComponents[4];
    
    if (isGreyscale) {
        newComponents[0] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[1] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[2] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[3] = oldComponents[1];
    }
    else {
        newComponents[0] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[1] = oldComponents[1] - value < 0.0f ? 0.0f : oldComponents[1] - value;
        newComponents[2] = oldComponents[2] - value < 0.0f ? 0.0f : oldComponents[2] - value;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *retColor = [UIColor colorWithCGColor:newColor];
    CGColorRelease(newColor);
    
    return retColor;
}


@end
