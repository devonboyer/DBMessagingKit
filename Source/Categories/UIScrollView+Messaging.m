//
//  UIScrollView+Messaging.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2015-02-11.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "UIScrollView+Messaging.h"

@implementation UIScrollView (Messaging)

- (UIImage *)snapshotVisibleRect {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size,
                                           YES,
                                           [UIScreen mainScreen].scale);
    
    CGPoint offset = self.contentOffset;
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -offset.x, -offset.y);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *visibleScrollViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return visibleScrollViewImage;
}

@end
