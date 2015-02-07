//
//  DBMessageInputView.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-19.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

#import "DBMessagingInputUtility.h"

@class DBMessageInputView;
@class DBMessagingInputTextView;

@protocol MessageInputViewDelegate <NSObject>

@optional
- (void)messageInputView:(DBMessageInputView *)view cameraButtonTapped:(UIButton *)cameraButton;
- (void)messageInputView:(DBMessageInputView *)view sendButtonTapped:(UIButton *)sendButton;

@end

@interface DBMessageInputView : UIView <DBMessagingInputUtility, UIAppearance>

@property (weak ,nonatomic) id <MessageInputViewDelegate> delegate;
@property (strong, nonatomic) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) NSInteger borderWidth UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) BOOL blur;
@property (strong, nonatomic, readonly) UIButton *cameraButton;
@property (strong, nonatomic, readonly) UIButton *sendButton;
@property (strong, nonatomic, readonly) DBMessagingInputTextView *textView;

@end
