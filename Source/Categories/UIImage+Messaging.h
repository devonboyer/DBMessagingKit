//
//  UIImage+Messaging.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-18.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

@interface UIImage (Messaging)

- (NSString *)encodeToBase64String;

+ (UIImage *)decodeBase64StringToImage:(NSString *)encodedString;

+ (UIImage *)imageByRoundingCorners:(CGFloat)cornerRadius ofImage:(UIImage *)image;

+ (UIImage *)imageWithBorder:(CGFloat)borderWidth color:(UIColor *)borderColor fromImage:(UIImage *)source;

/**
 *  Creates and returns a new image overlayed with the specified color.
 *
 *  @param color The color to overlay the receiver.
 *
 *  @return A new image overlayed with the specified color.
 */
- (UIImage *)imageWithColor:(UIColor *)color;

@end
