//
//  DBMessagingParentCell.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-17.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingParentCell.h"

#import "DBMessagingCollectionView.h"
#import "DBMessagingCollectionViewBaseFlowLayout.h"
#import "DBMessagingCollectionViewLayoutAttributes.h"

@interface DBMessagingParentCell () <UIGestureRecognizerDelegate>

@end

@implementation DBMessagingParentCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.messageBubbleImageView = [[UIImageView alloc] init];
        [self.messageBubbleImageView setClipsToBounds:YES];
        [self.messageBubbleImageView setUserInteractionEnabled:YES];
        [self.contentView addSubview:self.messageBubbleImageView];
        
        self.messageTopLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.messageTopLabel];
        
        self.cellTopLabel = [[UILabel alloc] init];
        [self.cellTopLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:self.cellTopLabel];
        
        self.cellBottomLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.cellBottomLabel];
        
        self.avatarImageView = [[UIImageView alloc] init];
        [self.avatarImageView setClipsToBounds:YES];
        [self.avatarImageView setUserInteractionEnabled:YES];
        [self.avatarImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.avatarImageView setBackgroundColor:[UIColor colorWithWhite:0.88 alpha:1.0]];
        [self.contentView addSubview:self.avatarImageView];
        
        self.accessoryImageView = [[UIImageView alloc] init];
        [self.accessoryImageView.layer setBorderWidth:2.0];
        [self.accessoryImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.accessoryImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.accessoryImageView setClipsToBounds:YES];
        //[self.contentView addSubview:self.accessoryImageView];

        UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarTap:)];
        [avatarTap setDelegate:self];
        [self.avatarImageView addGestureRecognizer:avatarTap];
    }
    return self;
}

- (void)applyLayoutAttributes:(DBMessagingCollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    self.messageTopLabelHeight = layoutAttributes.messageBubbleTopLabelHeight;
    self.cellTopLabelHeight = layoutAttributes.cellTopLabelHeight;
    self.cellBottomLabelHeight = layoutAttributes.cellBottomLabelHeight;
    self.messageBubbleLeftRightMargin = layoutAttributes.messageBubbleLeftRightMargin;
    self.outgoingAvatarSize = layoutAttributes.outgoingAvatarViewSize;
    self.incomingAvatarSize = layoutAttributes.incomingAvatarViewSize;
    self.incomingMessageBubbleAvatarSpacing = layoutAttributes.incomingMessageBubbleAvatarSpacing;
    self.outgoingMessageBubbleAvatarSpacing = layoutAttributes.outgoingMessageBubbleAvatarSpacing;
    self.messageBubbleTextContainerInsets = layoutAttributes.messageBubbleTextViewTextContainerInsets;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.cellTopLabel setFrame:CGRectMake(0,
                                           0,
                                           CGRectGetWidth(self.frame),
                                           self.cellTopLabelHeight)];
    
    switch (self.type) {
        case MessageBubbleTypeIncoming: {
            
            [self.messageTopLabel setTextAlignment:NSTextAlignmentLeft];
            [self.cellBottomLabel setTextAlignment:NSTextAlignmentLeft];
            
            [self.messageBubbleImageView setFrame:CGRectMake(self.incomingAvatarSize.width + self.incomingMessageBubbleAvatarSpacing,
                                                             CGRectGetMaxY(self.messageTopLabel.frame),
                                                             CGRectGetWidth(self.frame) - self.messageBubbleLeftRightMargin - self.incomingAvatarSize.width - self.incomingMessageBubbleAvatarSpacing,
                                                             CGRectGetHeight(self.frame) - self.cellTopLabelHeight - self.messageTopLabelHeight - self.cellBottomLabelHeight)];
            
            [self.messageTopLabel setFrame:CGRectMake(CGRectGetMinX(self.messageBubbleImageView.frame) + self.messageBubbleTextContainerInsets.left + self.messageBubbleTextContainerInsets.right,
                                                      CGRectGetMaxY(self.cellTopLabel.frame),
                                                      CGRectGetWidth(self.frame) - CGRectGetMinX(self.messageBubbleImageView.frame),
                                                      self.messageTopLabelHeight)];
            
            [self.cellBottomLabel setFrame:CGRectMake(CGRectGetMinX(self.messageBubbleImageView.frame),
                                                      CGRectGetMaxY(self.messageBubbleImageView.frame),
                                                      CGRectGetWidth(self.frame) - CGRectGetMinX(self.messageBubbleImageView.frame),
                                                      self.cellBottomLabelHeight)];
            
            [self.avatarImageView setFrame:CGRectMake(0, CGRectGetMaxY(self.messageBubbleImageView.frame) - self.incomingAvatarSize.height, self.incomingAvatarSize.width, self.incomingAvatarSize.height)];
            
            CGSize accessoryImageSize = CGSizeMake(self.incomingAvatarSize.width * 0.45, self.incomingAvatarSize.height * 0.45);
            [_accessoryImageView setFrame:CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) - accessoryImageSize.width / 1.2, CGRectGetMaxY(self.avatarImageView.frame) - accessoryImageSize.height / 1.2, accessoryImageSize.width, accessoryImageSize.height)];
            break;
        }
        case MessageBubbleTypeOutgoing: {
            
            [self.messageTopLabel setTextAlignment:NSTextAlignmentRight];
            [self.cellBottomLabel setTextAlignment:NSTextAlignmentRight];
            
            CGFloat bubbleWidth = CGRectGetWidth(self.frame) - self.messageBubbleLeftRightMargin;
            [self.messageBubbleImageView setFrame:CGRectMake(CGRectGetWidth(self.frame) - bubbleWidth,
                                                             CGRectGetMaxY(self.messageTopLabel.frame),
                                                             CGRectGetWidth(self.frame) - self.messageBubbleLeftRightMargin - self.outgoingAvatarSize.width - self.outgoingMessageBubbleAvatarSpacing,
                                                             CGRectGetHeight(self.frame) - self.cellTopLabelHeight - self.messageTopLabelHeight - self.cellBottomLabelHeight)];
            
            [self.messageTopLabel setFrame:CGRectMake(0,
                                                      CGRectGetMaxY(self.cellTopLabel.frame),
                                                      CGRectGetWidth(self.frame) - (CGRectGetWidth(self.frame) - CGRectGetMaxX(self.messageBubbleImageView.frame))  - self.messageBubbleTextContainerInsets.left - self.messageBubbleTextContainerInsets.right,
                                                      self.messageTopLabelHeight)];
            
            [self.cellBottomLabel setFrame:CGRectMake(CGRectGetMinX(self.messageBubbleImageView.frame),
                                                      CGRectGetMaxY(self.messageBubbleImageView.frame),
                                                      CGRectGetWidth(self.frame) - CGRectGetMinX(self.messageBubbleImageView.frame),
                                                      self.cellBottomLabelHeight)];
            
            [self.avatarImageView setFrame:CGRectMake(CGRectGetWidth(self.frame) - self.outgoingAvatarSize.width, CGRectGetMaxY(self.messageBubbleImageView.frame) - self.outgoingAvatarSize.height, self.outgoingAvatarSize.width, self.outgoingAvatarSize.height)];
            
            CGSize accessoryImageSize = CGSizeMake(self.outgoingAvatarSize.width * 0.45, self.outgoingAvatarSize.height * 0.45);
            [_accessoryImageView setFrame:CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) - accessoryImageSize.width / 1.2 - CGRectGetWidth(self.avatarImageView.frame), CGRectGetMaxY(self.avatarImageView.frame) - accessoryImageSize.height / 1.2 - CGRectGetHeight(self.avatarImageView.frame), accessoryImageSize.width, accessoryImageSize.height)];
            break;
        }
        default:
            break;
    }
    
    [self.avatarImageView.layer setCornerRadius:CGRectGetHeight(self.avatarImageView.frame) / 2.0];
    [self.accessoryImageView.layer setCornerRadius:CGRectGetHeight(self.accessoryImageView.frame) / 2.0];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.messageBubbleImageView.highlighted = highlighted;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.messageBubbleImageView.highlighted = selected;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.messageBubbleImageView.image = nil;
    self.messageBubbleImageView.highlightedImage = nil;
    self.messageBubbleImageView.alpha = 1.0;
}

#pragma mark - Setters

- (void)setHideAvatar:(BOOL)hideAvatar
{
    _hideAvatar = hideAvatar;
    [self.avatarImageView setHidden:hideAvatar];
    [self.accessoryImageView setHidden:hideAvatar];
}

#pragma mark - Actions

- (void)handleAvatarTap:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(messageCell:didTapAvatarImageView:)]) {
        [self.delegate messageCell:self didTapAvatarImageView:self.avatarImageView];
    }
}

@end
