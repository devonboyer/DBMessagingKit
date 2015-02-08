//
//  DBMessageInputView.m
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

#import "DBMessagingInputToolbar.h"

#import "DBMessagingInputTextView.h"
#import "UIColor+Messaging.h"

@interface DBMessagingInputToolbar () <DBMessagingInputTextViewDelegate>
{
    
    UIBarButtonItem *_flexibleSpace;
}

@property (strong, nonatomic) CALayer *topBorderLayer;
@property (strong, nonatomic) UIToolbar *blurToolbar;

@property (strong, nonatomic) DBMessagingInputTextView *textView;
@property (strong, nonatomic) UIToolbar *contentToolbar;

@end

@implementation DBMessagingInputToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _blurToolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        [_blurToolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:_blurToolbar];
        
        _contentToolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        _contentToolbar.translucent = true;
        [_contentToolbar setTintColor:[UIColor defaultToolbarTintColor]];
        [_contentToolbar setBarStyle:UIBarStyleBlack];
        [_contentToolbar setBackgroundColor:[UIColor clearColor]];
        [_contentToolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [_contentToolbar setShadowImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny];
        [_contentToolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        [self addSubview:_contentToolbar];
        
        _topBorderLayer = [CALayer layer];
        [self.layer addSublayer:_topBorderLayer];
        
        _textView = [[DBMessagingInputTextView alloc] initWithFrame:CGRectMake(0,0,0.0,30.0)];
        [_textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_textView setDelegate:self];
        [self addSubview:_textView];
        
        _blur = YES;
        _borderColor = [UIColor lightGrayColor];
        _borderWidth = 1.0;
        
        _flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [_contentToolbar setItems:@[_flexibleSpace]];

    }
    
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];

    NSInteger index = 0;
    UIBarButtonItem *innerLeftBarButtonItem;
    UIBarButtonItem *innerRightBarButtonItem;
    for (UIBarButtonItem *barButtonItem in _contentToolbar.items) {
        if (barButtonItem == _flexibleSpace) {
            if (index - 1 >= 0) {
                innerLeftBarButtonItem = _contentToolbar.items[index - 1];
            }
            
            if (index + 1 <= _contentToolbar.items.count - 1) {
                innerRightBarButtonItem = _contentToolbar.items[index + 1];
            }
        }
        index++;
    }
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 15.0, 0, 15.0);
    CGFloat margin = 8.0;

    if (innerLeftBarButtonItem) {
        UIView *innerLeftView = [innerLeftBarButtonItem valueForKey:@"view"];
        insets.left = CGRectGetMaxX(innerLeftView.frame) + margin;
    }
    
    if (innerRightBarButtonItem) {
        UIView *innerRightView = [innerRightBarButtonItem valueForKey:@"view"];
        insets.right = self.bounds.size.width - CGRectGetMinX(innerRightView.frame) + margin;
    }
    
    _textView.frame = CGRectMake(insets.left, 0, self.bounds.size.width - insets.left - insets.right, _textView.frame.size.height);
    _textView.center = CGPointMake(_textView.center.x, self.bounds.size.height / 2.0);
    
    [_topBorderLayer setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), _borderWidth)];
}

#pragma mark - Setters

- (void)setBlur:(BOOL)blur
{
    _blur = blur;
    
    if (blur) {
        [_topBorderLayer setOpacity:0.0];
        [_contentToolbar setAlpha:1.0];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    else {
        [_topBorderLayer setOpacity:1.0];
        [_contentToolbar setAlpha:0.0];
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

- (void)setSendBarButtonItem:(UIBarButtonItem *)sendBarButtonItem {
    
    _sendBarButtonItem = sendBarButtonItem;
    [self toggleSendButtonEnabled];
}

- (void)addItem:(UIBarButtonItem *)item position:(DBMessagingInputToolbarItemPosition)position animated:(BOOL)animated {
    
    NSMutableArray *mutableItems = [[NSMutableArray alloc] initWithArray:_contentToolbar.items];
    
    switch (position) {
        case DBMessagingInputToolbarItemPositionLeft:
            [mutableItems insertObject:item atIndex:0];
            break;
        case DBMessagingInputToolbarItemPositionRight:
            [mutableItems addObject:item];
            break;
        default:
            break;
    }
    
    [_contentToolbar setItems:mutableItems animated:animated];
    
    [self setNeedsLayout];
}

#pragma mark - Actions

- (void)toggleSendButtonEnabled
{
    if (_sendBarButtonItem) {
        _sendBarButtonItem.enabled = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
    }
}

#pragma mark - DBMessagingInputTextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self toggleSendButtonEnabled];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.delegate messagingInputToolbarDidBeginEditing:self];
}

- (void)textViewDidChangeFrame:(UITextView *)textView delta:(CGFloat)delta {
    [self.delegate messagingInputToolbar:self shouldChangeFrame:delta];
}

- (BOOL)textView:(DBMessagingInputTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@""]) {
        
        NSValue *rangeValue = [NSValue valueWithRange:range];
        
        if ([textView.attatchmentRanges containsObject:rangeValue]) {
            [textView removeImageAttatchmentAtRange:range];
        }
    }
    
    return true;
}

@end
