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

/**
 *  Creates and returns an image for a frame at a given time of a movie.
 *
 *  @discussion The given movieURL must be a path on disk, not the network.
 *
 *  @param time     The time of the frame in the movie.
 *  @param movieURL The local URL for the movie.
 *
 *  @return An image of a frame at the specified time.
 */
+ (UIImage *)imageForFrameAtTime:(NSTimeInterval)time movieURL:(NSURL *)movieURL;

/**
 *  Creates and returns a new image overlayed with the specified color.
 *
 *  @param color The color to overlay the receiver.
 *
 *  @return A new image overlayed with the specified color.
 */
- (UIImage *)imageWithColor:(UIColor *)color;

@end
