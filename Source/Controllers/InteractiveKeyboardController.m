//
//  InteractiveKeyboardController.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-10-05.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "InteractiveKeyboardController.h"

NSString * const InteractiveKeyboardDidChangeFrameNotification = @"InteractiveKeyboardDidChangeFrameNotification";
NSString * const InteractiveKeyboardDidChangeFrameUserInfoKey = @"InteractiveKeyboardDidChangeFrameUserInfoKey";

static void * kInteractiveKeyboardControllerKeyValueObservingContext = &kInteractiveKeyboardControllerKeyValueObservingContext;

@interface InteractiveKeyboardController ()

@property (weak, nonatomic) UIView *keyboardView;

@end

@implementation InteractiveKeyboardController

#pragma mark - Initialization

- (instancetype)initWithTextView:(UITextView *)textView
                     contextView:(UIView *)contextView
            panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
                        delegate:(id<InteractiveKeyboardControllerDelegate>)delegate

{
    NSParameterAssert(textView != nil);
    NSParameterAssert(contextView != nil);
    NSParameterAssert(panGestureRecognizer != nil);
    
    self = [super init];
    if (self) {
        _textView = textView;
        _contextView = contextView;
        _panGestureRecognizer = panGestureRecognizer;
        _delegate = delegate;
    }
    return self;
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForNotfications
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

#pragma mark - Setters

- (void)setKeyboardView:(UIView *)keyboardView
{
    if (_keyboardView) {
        [self removeKeyboardFrameObserver];
    }
    
    _keyboardView = keyboardView;
    
    if (keyboardView) {
        [_keyboardView addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(frame))
                           options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                           context:kInteractiveKeyboardControllerKeyValueObservingContext];
    }
}

#pragma mark - Getters

- (BOOL)keyboardIsVisible
{
    return self.keyboardView != nil;
}

- (CGRect)currentKeyboardFrame
{
    if (!self.keyboardIsVisible) {
        return CGRectNull;
    }
    
    return self.keyboardView.frame;
}

#pragma mark - Keyboard controller

- (void)beginListeningForKeyboard
{
    self.textView.inputAccessoryView = [[UIView alloc] init];
    [self registerForNotfications];
}

- (void)endListeningForKeyboard
{
    self.textView.inputAccessoryView = nil;
    
    [self unregisterForNotifications];
    [self setKeyboardViewHidden:NO];
    
    self.keyboardView = nil;
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(keyboardControllerWillAppear:)]) {
        [self.delegate keyboardControllerWillAppear:self];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    self.keyboardView = self.textView.inputAccessoryView.superview;
    [self setKeyboardViewHidden:NO];
    
    [self handleKeyboardNotification:notification completion:^(BOOL finished) {
        [self.panGestureRecognizer addTarget:self action:@selector(handlePanGestureRecognizer:)];
    }];
    
    if ([self.delegate respondsToSelector:@selector(keyboardControllerDidAppear:)]) {
        [self.delegate keyboardControllerDidAppear:self];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    [self handleKeyboardNotification:notification completion:nil];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    [self setKeyboardViewHidden:NO];
    
    [self handleKeyboardNotification:notification completion:nil];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    self.keyboardView = nil;
    
    [self handleKeyboardNotification:notification completion:^(BOOL finished) {
        [self.panGestureRecognizer removeTarget:self action:NULL];
    }];
}

- (void)handleKeyboardNotification:(NSNotification *)notification completion:(void (^)(BOOL finished))completion
{
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (CGRectIsNull(keyboardEndFrame)) {
        return;
    }
    
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSInteger animationCurveOption = (animationCurve << 16);
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyboardEndFrameConverted = [self.contextView convertRect:keyboardEndFrame fromView:nil];
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurveOption
                     animations:^{
                         [self notifyKeyboardFrameNotificationForFrame:keyboardEndFrameConverted];
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion(finished);
                         }
                     }];
}

#pragma mark - Utilities

- (void)setKeyboardViewHidden:(BOOL)hidden
{
    self.keyboardView.hidden = hidden;
    self.keyboardView.userInteractionEnabled = !hidden;
}

- (void)notifyKeyboardFrameNotificationForFrame:(CGRect)frame
{
    [self.delegate keyboardController:self keyboardDidChangeFrame:frame];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:InteractiveKeyboardDidChangeFrameNotification
                                                        object:self
                                                      userInfo:@{InteractiveKeyboardDidChangeFrameUserInfoKey : [NSValue valueWithCGRect:frame]}];
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kInteractiveKeyboardControllerKeyValueObservingContext) {
        
        if (object == self.keyboardView && [keyPath isEqualToString:NSStringFromSelector(@selector(frame))]) {
            
            CGRect oldKeyboardFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
            CGRect newKeyboardFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
            
            if (CGRectEqualToRect(newKeyboardFrame, oldKeyboardFrame) || CGRectIsNull(newKeyboardFrame)) {
                return;
            }
            
            //  do not convert frame to contextView coordinates here
            //  KVO is triggered during panning (see below)
            //  panning occurs in contextView coordinates already
            [self notifyKeyboardFrameNotificationForFrame:newKeyboardFrame];
        }
    }
}


- (void)removeKeyboardFrameObserver
{
    @try {
        [_keyboardView removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(frame))
                              context:kInteractiveKeyboardControllerKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
}

#pragma mark - Pan gesture recognizer

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)pan
{
    CGPoint touch = [pan locationInView:self.contextView];
    
    //  system keyboard is added to a new UIWindow, need to operate in window coordinates
    //  also, keyboard always slides from bottom of screen, not the bottom of a view
    CGFloat contextViewWindowHeight = CGRectGetHeight(self.contextView.window.frame);
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        contextViewWindowHeight = CGRectGetWidth(self.contextView.window.frame);
    }
    
    CGFloat keyboardViewHeight = CGRectGetHeight(self.keyboardView.frame);
    
    CGFloat dragThresholdY = (contextViewWindowHeight - keyboardViewHeight - self.keyboardTriggerPoint.y);
    
    CGRect newKeyboardViewFrame = self.keyboardView.frame;
    
    BOOL userIsDraggingNearThresholdForDismissing = (touch.y > dragThresholdY);
    
    self.keyboardView.userInteractionEnabled = !userIsDraggingNearThresholdForDismissing;
    
    switch (pan.state) {
        case UIGestureRecognizerStateChanged:
        {
            newKeyboardViewFrame.origin.y = touch.y + self.keyboardTriggerPoint.y;
            
            //  bound frame between bottom of view and height of keyboard
            newKeyboardViewFrame.origin.y = MIN(newKeyboardViewFrame.origin.y, contextViewWindowHeight);
            newKeyboardViewFrame.origin.y = MAX(newKeyboardViewFrame.origin.y, contextViewWindowHeight - keyboardViewHeight);
            
            if (CGRectGetMinY(newKeyboardViewFrame) == CGRectGetMinY(self.keyboardView.frame)) {
                return;
            }
            
            [UIView animateWithDuration:0.0
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionNone
                             animations:^{
                                 self.keyboardView.frame = newKeyboardViewFrame;
                             }
                             completion:nil];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            BOOL keyboardViewIsHidden = (CGRectGetMinY(self.keyboardView.frame) >= contextViewWindowHeight);
            if (keyboardViewIsHidden) {
                return;
            }
            
            CGPoint velocity = [pan velocityInView:self.contextView];
            BOOL userIsScrollingDown = (velocity.y > 0.0f);
            BOOL shouldHide = (userIsScrollingDown && userIsDraggingNearThresholdForDismissing);
            
            newKeyboardViewFrame.origin.y = shouldHide ? contextViewWindowHeight : (contextViewWindowHeight - keyboardViewHeight);
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseOut
                             animations:^{
                                 self.keyboardView.frame = newKeyboardViewFrame;
                             }
                             completion:^(BOOL finished) {
                                 self.keyboardView.userInteractionEnabled = !shouldHide;
                                 
                                 if (shouldHide) {
                                     [self setKeyboardViewHidden:YES];
                                     [self.textView resignFirstResponder];
                                     [self removeKeyboardFrameObserver];
                                 }
                             }];
        }
            break;
            
        default:
            break;
    }
}


@end
