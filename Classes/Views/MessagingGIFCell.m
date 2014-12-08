//
//  MessagingGIFCell.m
//  MessagingKit
//
//  Created by Devon Boyer on 2014-12-07.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingGIFCell.h"

#import "UIImage+AnimatedGIF.h"

@interface MessagingGIFCell ()
{
    BOOL _animating;
}

@property (strong, nonatomic) UIImage *cachedAnimatedImage;

@end

@implementation MessagingGIFCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageView stopAnimating];
}

#pragma mark - Setters

- (void)setAnimatedGIFData:(NSData *)animatedGIFData {
    _animatedGIFData = animatedGIFData;
    
    self.messageBubbleImageView.highlightedImage = nil;
    
    if (!_cachedAnimatedImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _cachedAnimatedImage = [UIImage animatedImageWithAnimatedGIFData:animatedGIFData];
            self.imageView.animationImages = _cachedAnimatedImage.images;
            self.imageView.animationDuration = _cachedAnimatedImage.duration;
            [self.imageView startAnimating];
            
        });
    }
    else {
        self.imageView.animationImages = _cachedAnimatedImage.images;
        self.imageView.animationDuration = _cachedAnimatedImage.duration;
        [self.imageView startAnimating];
    }
}

#pragma mark - Getters

- (BOOL)animating {
    return self.imageView.isAnimating;
}

#pragma mark - Public

- (void)startAnimating {
    [self.imageView startAnimating];
}

- (void)stopAnimating {
    [self.imageView stopAnimating];
}

@end
