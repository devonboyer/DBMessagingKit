//
//  UIColor+Messaging.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-09-18.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Messaging)

+ (UIColor *)iMessageGrayColor;
+ (UIColor *)iMessageBlueColor;
+ (UIColor *)iMessageGreenColor;

- (UIColor *)colorByDarkeningColorWithValue:(CGFloat)value;

@end
