//
//  MessageBubbleFactory.m
//  MessagingKit
//
//  Created by Devon Boyer on 2014-09-01.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessageBubbleFactory.h"
#import "UIImage+Messaging.h"
#import "UIColor+Messaging.h"

@implementation MessageBubbleFactory

#pragma mark - Public

+ (UIImageView *)outgoingMessageBubbleImageWithColor:(UIColor *)color template:(UIImage *)bubbleTemplate{
    NSParameterAssert(bubbleTemplate != nil);
    return [MessageBubbleFactory bubbleImageWithColor:color flippedForIncoming:NO template:bubbleTemplate];
}

+ (UIImageView *)incomingMessageBubbleImageWithColor:(UIColor *)color template:(UIImage *)bubbleTemplate {
    NSParameterAssert(bubbleTemplate != nil);
    return [MessageBubbleFactory bubbleImageWithColor:color flippedForIncoming:YES template:bubbleTemplate];
}

#pragma mark - Private

+ (UIImageView *)bubbleImageWithColor:(UIColor *)color flippedForIncoming:(BOOL)flippedForIncoming template:(UIImage *)bubbleTemplate {
    
    UIImage *bubble = bubbleTemplate;
    
    UIImage *normalBubble = [bubble imageWithColor:color];
    UIImage *highlightedBubble = [bubble imageWithColor:[color colorByDarkeningColorWithValue:0.08f]];
    
    if (flippedForIncoming) {
        normalBubble = [MessageBubbleFactory horizontallyFlippedImageFromImage:normalBubble];
        highlightedBubble = [MessageBubbleFactory horizontallyFlippedImageFromImage:highlightedBubble];
    }
    
    // Make image stretchable from center point
    CGPoint center = CGPointMake(bubble.size.width / 2.0f, bubble.size.height / 2.0f);
    UIEdgeInsets capInsets = UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
    
    normalBubble = [MessageBubbleFactory stretchableImageFromImage:normalBubble withCapInsets:capInsets];
    highlightedBubble = [MessageBubbleFactory stretchableImageFromImage:highlightedBubble withCapInsets:capInsets];
    
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
