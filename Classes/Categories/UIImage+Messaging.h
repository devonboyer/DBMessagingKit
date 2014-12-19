//
//  UIImage+Messaging.h
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-09-18.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Messaging)

+ (UIImage *)imageForFrameAtTime:(NSTimeInterval)time movieURL:(NSURL *)movieURL;

/**
 *  Creates and returns a new image overlayed with the spcified color.
 *
 *  @param color The color to overlay the receiver.
 *
 *  @return A new image overlayed with the spcified color.
 */
- (UIImage *)imageWithColor:(UIColor *)color;

@end
