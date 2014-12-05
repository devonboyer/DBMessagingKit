//
//  MessageInputView.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-09-19.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MessagingInputUtility.h"

@class MessageInputView;
@class MessagingInputTextView;

@protocol MessageInputViewDelegate <NSObject>

@optional
- (void)messageInputView:(MessageInputView *)view cameraButtonTapped:(UIButton *)cameraButton;
- (void)messageInputView:(MessageInputView *)view sendButtonTapped:(UIButton *)sendButton;

@end

@interface MessageInputView : UIView <MessagingInputUtility, UIAppearance>

@property (weak ,nonatomic) id <MessageInputViewDelegate> delegate;
@property (strong, nonatomic) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) NSInteger borderWidth UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) BOOL blur;
@property (strong, nonatomic, readonly) UIButton *cameraButton;
@property (strong, nonatomic, readonly) UIButton *sendButton;
@property (strong, nonatomic, readonly) MessagingInputTextView *textView;

@end
