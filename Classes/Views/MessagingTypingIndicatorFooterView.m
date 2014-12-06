//
//  MessagingTypingIndicatorFooterView.m
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-09-23.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingTypingIndicatorFooterView.h"

#import "MessagingCollectionViewLayoutAttributes.h"

@interface MessagingTypingIndicatorFooterView ()
{
    UIImageView *_typingIndicatorImageView;
}

@property (assign, nonatomic) UIEdgeInsets messageBubbleTextContainerInsets;
@property (assign, nonatomic) CGSize incomingAvatarSize;
@property (assign, nonatomic) CGSize outgoingAvatarSize;

@end

@implementation MessagingTypingIndicatorFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _typingIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TypingBubble1"]];
        [_typingIndicatorImageView setFrame:CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
        [_typingIndicatorImageView setContentMode:UIViewContentModeScaleAspectFit];
        [_typingIndicatorImageView setClipsToBounds:YES];
        [_typingIndicatorImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self addSubview:_typingIndicatorImageView];
        
        /*
        NSInteger numberOfImages = 3;
        NSMutableArray *animationImages = [[NSMutableArray alloc] init];
        for (int i = 0; i < numberOfImages; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"TypingBubble%d", i + 1]];
            [animationImages addObject:image];
        }
        _typingIndicatorImageView.animationImages = animationImages;
        _typingIndicatorImageView.animationRepeatCount = INT16_MAX;
        _typingIndicatorImageView.animationDuration = 1.0;
         */
    }
    return self;
}

- (void)applyLayoutAttributes:(MessagingCollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    self.incomingAvatarSize = layoutAttributes.incomingAvatarViewSize;
    self.outgoingAvatarSize = layoutAttributes.outgoingAvatarViewSize;
    self.messageBubbleTextContainerInsets = layoutAttributes.messageBubbleTextViewTextContainerInsets;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_typingIndicatorImageView sizeToFit];
    [_typingIndicatorImageView setFrame:CGRectMake(0, 0, CGRectGetWidth(_typingIndicatorImageView.frame), CGRectGetHeight(self.bounds) - 10.0)];
    [_typingIndicatorImageView setCenter:CGPointMake(CGRectGetMidX(_typingIndicatorImageView.frame), CGRectGetHeight(self.frame) / 2.0)];
    
}

@end
