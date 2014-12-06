//
//  MessagingTimestampSupplementaryView.m
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-10-11.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingTimestampSupplementaryView.h"
#import "MessagingCollectionViewLayoutAttributes.h"

@interface MessagingTimestampSupplementaryView ()

@property (assign, nonatomic) UIEdgeInsets messageBubbleTextContainerInsets;
@property (assign, nonatomic) CGSize incomingAvatarSize;
@property (assign, nonatomic) CGSize outgoingAvatarSize;

@property (strong, nonatomic) UILabel *timestampLabel;

@end

@implementation MessagingTimestampSupplementaryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _timestampLabel = [[UILabel alloc] init];
        [_timestampLabel setTextAlignment:NSTextAlignmentCenter];
        [_timestampLabel setNumberOfLines:1];
        [self addSubview:_timestampLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch (self.type) {
        case IGChatMessageBubbleTypeIncoming: {
            [_timestampLabel setFrame:CGRectMake(self.incomingAvatarSize.width + self.messageBubbleTextContainerInsets.right + self.messageBubbleTextContainerInsets.left, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
            break;
        }
        case IGChatMessageBubbleTypeOutgoing: {
            [_timestampLabel setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds) - self.outgoingAvatarSize.width - self.messageBubbleTextContainerInsets.right - self.messageBubbleTextContainerInsets.left, CGRectGetHeight(self.bounds))];
            break;
        }
        default:
            break;
    }
}

- (void)applyLayoutAttributes:(MessagingCollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    self.incomingAvatarSize = layoutAttributes.incomingAvatarViewSize;
    self.outgoingAvatarSize = layoutAttributes.outgoingAvatarViewSize;
    self.messageBubbleTextContainerInsets = layoutAttributes.messageBubbleTextViewTextContainerInsets;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.timestampLabel.text = @"";
    self.timestampLabel.attributedText = nil;
}

#pragma mark - Setters

- (void)setType:(IGChatMessageBubbleType)type
{
    _type = type;
    
    switch (type) {
        case IGChatMessageBubbleTypeIncoming: {
            [self.timestampLabel setTextAlignment:NSTextAlignmentLeft];
            break;
        }
        case IGChatMessageBubbleTypeOutgoing: {
            [self.timestampLabel setTextAlignment:NSTextAlignmentRight];
            break;
        }
        default:
            break;
    }
    
    [self setNeedsLayout];
}

@end
