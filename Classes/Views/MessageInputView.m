//
//  MessageInputView.m
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-09-19.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessageInputView.h"

#import "MessagingInputTextView.h"
#import "UIColor+Messaging.h"

@interface MessageInputView ()

@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) MessagingInputTextView *textView;

@property (strong, nonatomic) CALayer *topBorderLayer;
@property (strong, nonatomic) UIToolbar *blurToolbar;

@end

@implementation MessageInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _blurToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        [_blurToolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:_blurToolbar];
        
        _topBorderLayer = [CALayer layer];
        [self.layer addSublayer:_topBorderLayer];
        
        CGSize cameraButtonSize = CGSizeMake(44.0f, 44.0f);
        CGSize sendButtonSize = CGSizeMake(44.0f, 44.0f);
        CGFloat initialTextViewHeight = 30.0;
        CGFloat padding = 5.0f;
        
        _cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) / 2.0 - cameraButtonSize.width / 2.0, cameraButtonSize.width, cameraButtonSize.height)];
        [_cameraButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin];
        [_cameraButton addTarget:self action:@selector(cameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_cameraButton setImage:[UIImage imageNamed:@"camera_button"] forState:UIControlStateNormal];
        [self addSubview:_cameraButton];
        
        _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - sendButtonSize.width - padding, CGRectGetHeight(self.frame) / 2.0 - sendButtonSize.height / 2.0, sendButtonSize.width, sendButtonSize.height)];
        [_sendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [_sendButton setTitleColor:[UIColor iMessageBlueColor] forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_sendButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
        [_sendButton addTarget:self action:@selector(sendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self addSubview:_sendButton];
        
        _textView = [[MessagingInputTextView alloc] initWithFrame:CGRectMake(cameraButtonSize.width, CGRectGetHeight(self.frame) / 2.0 - initialTextViewHeight / 2.0, self.frame.size.width - cameraButtonSize.width - sendButtonSize.width - padding * 2.0, initialTextViewHeight)];
        [_textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:_textView];
        
        _blur = YES;
        _borderColor = [UIColor lightGrayColor];
        _borderWidth = 1.0;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_topBorderLayer setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), _borderWidth)];
}

#pragma mark - Setters

- (void)setBlur:(BOOL)blur
{
    _blur = blur;
    
    if (blur) {
        [_topBorderLayer setOpacity:0.0];
        [_blurToolbar setAlpha:1.0];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    else {
        [_topBorderLayer setOpacity:1.0];
        [_blurToolbar setAlpha:0.0];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)setBorderWidth:(NSInteger)borderWidth
{
    _borderWidth = borderWidth;
    [self setNeedsLayout];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [_topBorderLayer setBackgroundColor:borderColor.CGColor];
}

#pragma mark - Actions

- (void)cameraButtonTapped:(id)sender
{
    if ([_delegate respondsToSelector:@selector(messageInputView:cameraButtonTapped:)]) {
        [_delegate messageInputView:self cameraButtonTapped:sender];
    }
}

- (void)sendButtonTapped:(id)sender
{
    if ([_delegate respondsToSelector:@selector(messageInputView:sendButtonTapped:)]) {
        [_delegate messageInputView:self sendButtonTapped:sender];
    }
}

@end
