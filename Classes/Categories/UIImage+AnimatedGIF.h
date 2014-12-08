//
//  UIImage+AnimatedGIF.h
//  MessagingKit
//
//  GitHub
//  https://github.com/mayoff/uiimage-from-animated-gif
//
//  Created by Rob Mayoff on 2012-01-27.
//  Copyright (c) 2014 Rob Mayoff. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AnimatedGIF)

/**
 *  The data is interpreted as a GIF to create an animated 'UIImage' using the source images in the GIF. The GIF stores a separate
 *  duration for each frame, in units of centiseconds (hundredths of a second).  However, a 'UIImage' only has a single, total
 *  'duration' property, which is a floating-point number. To handle this mismatch, each source image (from the GIF) is added to
 *  'animation' a varying number of times to match the ratios between the frame durations in the GIF.
 *
 *  For example, suppose the GIF contains three frames.  Frame 0 has duration 3.  Frame 1 has duration 9.  Frame 2 has duration 15.
 *  Each duration is divided by the greatest common denominator of all the durations, which is 3, and add each frame the resulting 
 *  number of times.  Thus 'animation' will contain frame 0 3/3 = 1 time, then frame 1 9/3 = 3 times, then frame 2 15/3 = 5 times.
 *  The 'animation.duration' is set to (3+9+15)/100 = 0.27 seconds.
 *
 *  @param data The data embedded in the GIF.
 *
 *  @return An animated UIImage that displays a GIF.
 */
+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)data;

/**
 * The contents of the URL are interpreted as a GIF to create an animated 'UIImage' using the source images in the GIF.
 *
 * @param url The URL that contains the GIF.
 *
 * @return An animated UIImage that displays a GIF.
 */
+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)url;

@end
