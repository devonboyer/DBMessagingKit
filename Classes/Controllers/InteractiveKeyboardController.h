//
//  InteractiveKeyboardController.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-10-05.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InteractiveKeyboardController;

@protocol InteractiveKeyboardControllerDelegate <NSObject>

@required
- (void)keyboardController:(InteractiveKeyboardController *)keyboardController keyboardDidChangeFrame:(CGRect)keyboardFrame;

@end

@interface InteractiveKeyboardController : NSObject

@property (weak, nonatomic) id<InteractiveKeyboardControllerDelegate> delegate;
@property (weak, nonatomic) UITextView *textView;
@property (weak, nonatomic) UIView *contextView;
@property (weak, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (assign, nonatomic) CGPoint keyboardTriggerPoint;
@property (assign, nonatomic) CGRect currentKeyboardFrame;
@property (assign, nonatomic) BOOL keyboardIsVisible;


- (instancetype)initWithTextView:(UITextView *)textView
                     contextView:(UIView *)contextView
            panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
                        delegate:(id<InteractiveKeyboardControllerDelegate>)delegate;

- (void)beginListeningForKeyboard;
- (void)endListeningForKeyboard;

@end
