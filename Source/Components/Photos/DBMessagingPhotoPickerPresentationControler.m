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

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];

    // Add the dimming view and the presented view to the heirarchy
    _dimmingView = [[UIView alloc] init];
    _dimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _dimmingView.frame = self.containerView.bounds;
    _dimmingView.alpha = 0.0;
    
    _dimmingViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [_dimmingView addGestureRecognizer:_dimmingViewTap];
    
    [self.containerView addSubview:_dimmingView];
    [self.containerView addSubview:self.presentedView];
    
    // Fade in the dimming view alongside the transition
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        _dimmingView.alpha = 1.0;
    } completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    [super presentationTransitionDidEnd:completed];
    
    // If the presentation didn't complete, remove the dimming view
    if (!completed) {
        [_dimmingView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin {
    [super dismissalTransitionWillBegin];
    
    // Fade out the dimming view alongside the transition
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        _dimmingView.alpha = 0.0;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    [super dismissalTransitionDidEnd:completed];
    
    // If the dismissal completed, remove the dimming view
    if (completed) {
        [_dimmingView removeFromSuperview];
    }
}

- (CGRect)frameOfPresentedViewInContainerView {
    CGRect frame = self.containerView.frame;
    frame.size.height = self.containerView.frame.size.height / 2.0;
    frame.origin.y = self.containerView.frame.size.height  - frame.size.height;
    return frame;
}

#pragma mark - Actions

- (void)dismiss:(id)sender {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
