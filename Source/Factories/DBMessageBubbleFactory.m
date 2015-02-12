//
//  DBMessageBubbleFactory.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-01.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessageBubbleFactory.h"
#import "UIImage+Messaging.h"
#import "UIColor+Messaging.h"

@implementation DBMessageBubbleFactory

#pragma mark - Public

+ (UIImageView *)outgoingMessageBubbleImageWithColor:(UIColor *)color template:(UIImage *)bubbleTemplate{
    NSParameterAssert(bubbleTemplate != nil);
    return [DBMessageBubbleFactory bubbleImageWithColor:color flippedForIncoming:NO template:bubbleTemplate];
}

+ (UIImageView *)incomingMessageBubbleImageWithColor:(UIColor *)color template:(UIImage *)bubbleTemplate {
    NSParameterAssert(bubbleTemplate != nil);
    return [DBMessageBubbleFactory bubbleImageWithColor:color flippedForIncoming:YES template:bubbleTemplate];
}

#pragma mark - Private

+ (UIImageView *)bubbleImageWithColor:(UIColor *)color flippedForIncoming:(BOOL)flippedForIncoming template:(UIImage *)bubbleTemplate {
    
    UIImage *bubble = bubbleTemplate;
    
    UIImage *normalBubble = [bubble imageOverlayedWithColor:color];
    UIImage *highlightedBubble = [bubble imageOverlayedWithColor:[color colorByDarkeningColorWithValue:0.08f]];
    
    if (flippedForIncoming) {
        normalBubble = [DBMessageBubbleFactory horizontallyFlippedImageFromImage:normalBubble];
        highlightedBubble = [DBMessageBubbleFactory horizontallyFlippedImageFromImage:highlightedBubble];
    }
    
    // Make image stretchable from center point
    CGPoint center = CGPointMake(bubble.size.width / 2.0f, bubble.size.height / 2.0f);
    UIEdgeInsets capInsets = UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
    
    normalBubble = [DBMessageBubbleFactory stretchableImageFromImage:normalBubble withCapInsets:capInsets];
    highlightedBubble = [DBMessageBubbleFactory stretchableImageFromImage:highlightedBubble withCapInsets:capInsets];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:normalBubble highlightedImage:highlightedBubble];
    imageView.backgroundColor = [UIColor whiteColor];
    return imageView;
}

+ (UIImage *)horizontallyFlippedImageFromImage:(UIImage *)image {
    return [UIImage imageWithCGImage:image.CGImage
                               scale:image.scale
                         orientation:UIImageOrientationUpMirrored];
}

+ (UIImage *)stretchableImageFromImage:(UIImage *)image withCapInsets:(UIEdgeInsets)capInsets {
    return [image resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
}

@end
