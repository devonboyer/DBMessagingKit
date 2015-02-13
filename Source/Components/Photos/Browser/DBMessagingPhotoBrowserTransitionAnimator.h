//
//  DBMessagingPhotoBrowserTransitionAnimator.h
//  DBMessagingKit
//
//  Created by Devon Boyer on 2015-02-12.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBMessagingPhotoBrowserTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic, readonly) CGRect sourceRect;

@property (assign, nonatomic, readonly) CGRect destinationRect;

@property (assign, nonatomic, readonly) UIImage *transitionPhoto;

- (instancetype)initWithSourceRect:(CGRect)sourceRect destinationRect:(CGRect)destinationRect transitionPhoto:(UIImage *)transitionPhoto;

@end
