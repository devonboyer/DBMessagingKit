//
//  DBMessagingPhotoBrowserTransitionAnimator.m
//  DBMessagingKit
//
//  Created by Devon Boyer on 2015-02-12.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBMessagingPhotoBrowserTransitionAnimator.h"

@implementation DBMessagingPhotoBrowserTransitionAnimator

- (instancetype)initWithSourceRect:(CGRect)sourceRect destinationRect:(CGRect)destinationRect transitionPhoto:(UIImage *)transitionPhoto {
    self = [super init];
    if (self) {
        _sourceRect = sourceRect;
        _destinationRect = destinationRect;
        _transitionPhoto = transitionPhoto;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.34;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
}

@end
