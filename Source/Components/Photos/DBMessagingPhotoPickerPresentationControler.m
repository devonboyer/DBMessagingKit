//
//  DBMessagingPhotoPickerPresentationControler.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2015-02-10.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingPhotoPickerPresentationControler.h"

@interface DBMessagingPhotoPickerPresentationControler ()

@property (strong, nonatomic) UIView *dimmingView;
@property (strong, nonatomic) UITapGestureRecognizer *dimmingViewTap;

@end

@implementation DBMessagingPhotoPickerPresentationControler

#pragma mark - Getters

- (UIView *)dimmingView {
    
    if (!_dimmingView) {
        _dimmingView = [[UIView alloc] init];
        _dimmingView.frame = self.containerView.bounds;
        _dimmingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _dimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _dimmingView.alpha = 0.0;
        
        _dimmingViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [_dimmingView addGestureRecognizer:_dimmingViewTap];
    }
    
    return _dimmingView;
}

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];

    // Add the dimming view and the presented view to the heirarchy
    [self.containerView addSubview:self.dimmingView];
    [self.containerView addSubview:self.presentedView];
    
    // Fade in the dimming view alongside the transition
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 1.0;
    } completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    [super presentationTransitionDidEnd:completed];
    
    // If the presentation didn't complete, remove the dimming view
    if (!completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin {
    [super dismissalTransitionWillBegin];
    
    // Fade out the dimming view alongside the transition
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 0.0;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    [super dismissalTransitionDidEnd:completed];
    
    // If the dismissal completed, remove the dimming view
    if (completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (CGRect)frameOfPresentedViewInContainerView {
    CGRect superFrame = [super frameOfPresentedViewInContainerView];
    
    CGRect frame = superFrame;
    frame.size.height = MAX(290.0, superFrame.size.height * 0.7);
    frame.origin.y = superFrame.size.height  - frame.size.height;
    return frame;
}

#pragma mark - Actions

- (void)dismiss:(id)sender {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
