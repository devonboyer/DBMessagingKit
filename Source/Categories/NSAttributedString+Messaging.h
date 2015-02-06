//
//  NSAttributedString+Messaging.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-23.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

@interface NSAttributedString (Messaging)

/**
 *  Calculates and returns the size of the bounding box of an attributed string that fits the 
 *  speficied maxWidth.
 *
 *  @param attributedString The attributed string.
 *  @param maxWidth The maximum width for the bounding box that contains with attributed string.
 *
 *  @return The size of the bounding box that fits the specified maxWidth.
 */
+ (CGSize)boundingBoxForAttributedString:(NSAttributedString *)attributedString maxWidth:(CGFloat)maxWidth;

@end
