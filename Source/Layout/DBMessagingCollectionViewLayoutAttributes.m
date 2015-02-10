//
//  DBMessagingCollectionViewLayoutAttributes.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-22.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingCollectionViewLayoutAttributes.h"

#pragma mark - Setters

@implementation DBMessagingCollectionViewLayoutAttributes

- (void)setMessageBubbleFont:(UIFont *)messageBubbleFont
{
    NSParameterAssert(messageBubbleFont != nil);
    _messageBubbleFont = messageBubbleFont;
}

- (void)setMessageBubbleLeftRightMargin:(CGFloat)messageBubbleLeftRightMargin
{
    NSParameterAssert(messageBubbleLeftRightMargin >= 0.0f);
    _messageBubbleLeftRightMargin = ceilf(messageBubbleLeftRightMargin);
}

- (void)setMessageBubbleTopLabelHeight:(CGFloat)messageBubbleTopLabelHeight
{
    NSParameterAssert(messageBubbleTopLabelHeight >= 0);
    _messageBubbleTopLabelHeight = floorf(messageBubbleTopLabelHeight);
}

- (void)setCellTopLabelHeight:(CGFloat)messageTopLabelHeight
{
    NSParameterAssert(messageTopLabelHeight >= 0);
    _cellTopLabelHeight = floorf(messageTopLabelHeight);
}

- (void)setCellBottomLabelHeight:(CGFloat)messageBottomLabelHeight
{
    NSParameterAssert(messageBottomLabelHeight >= 0);
    _cellBottomLabelHeight = floorf(messageBottomLabelHeight);
}

- (void)setIncomingAvatarViewSize:(CGSize)incomingAvatarViewSize
{
    NSParameterAssert(incomingAvatarViewSize.width >= 0.0f && incomingAvatarViewSize.height >= 0.0f);
    NSParameterAssert(incomingAvatarViewSize.height == incomingAvatarViewSize.width);
    _incomingAvatarViewSize = CGSizeMake(ceil(incomingAvatarViewSize.width), ceilf(incomingAvatarViewSize.height));
}

- (void)setOutgoingAvatarViewSize:(CGSize)outgoingAvatarViewSize
{
    NSParameterAssert(outgoingAvatarViewSize.width >= 0.0f && outgoingAvatarViewSize.height >= 0.0f);
    NSParameterAssert(outgoingAvatarViewSize.height == outgoingAvatarViewSize.width);
    _outgoingAvatarViewSize = CGSizeMake(ceil(outgoingAvatarViewSize.width), ceilf(outgoingAvatarViewSize.height));
}

- (void)setIncomingMediaViewSize:(CGSize)incomingImageSize
{
    NSParameterAssert(incomingImageSize.width >= 0.0f && incomingImageSize.height >= 0.0f);
    _incomingMediaViewSize = CGSizeMake(ceil(incomingImageSize.width), ceilf(incomingImageSize.height));
}

- (void)setOutgoingMediaViewSize:(CGSize)outgoingImageSize
{
    NSParameterAssert(outgoingImageSize.width >= 0.0f && outgoingImageSize.height >= 0.0f);
    _outgoingMediaViewSize = CGSizeMake(ceil(outgoingImageSize.width), ceilf(outgoingImageSize.height));
}

- (void)setIncomingMessageBubbleAvatarSpacing:(CGFloat)incomingMessageBubbleAvatarSpacing
{
    NSParameterAssert(incomingMessageBubbleAvatarSpacing >= 0.0f);
    _incomingMessageBubbleAvatarSpacing = incomingMessageBubbleAvatarSpacing;
}

- (void)setOutgoingMessageBubbleAvatarSpacing:(CGFloat)outgoingMessageBubbleAvatarSpacing
{
    NSParameterAssert(outgoingMessageBubbleAvatarSpacing >= 0.0f);
    _outgoingMessageBubbleAvatarSpacing = outgoingMessageBubbleAvatarSpacing;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    DBMessagingCollectionViewLayoutAttributes *copy = [super copyWithZone:zone];
    
    if (copy.representedElementCategory != UICollectionElementCategoryCell) {
        return copy;
    }
    
    copy.messageBubbleFont = self.messageBubbleFont;
    copy.messageBubbleLeftRightMargin = self.messageBubbleLeftRightMargin;
    copy.messageBubbleTopLabelHeight = self.messageBubbleTopLabelHeight;
    copy.cellTopLabelHeight = self.cellTopLabelHeight;
    copy.cellBottomLabelHeight = self.cellBottomLabelHeight;
    copy.messageBubbleTextViewTextContainerInsets = self.messageBubbleTextViewTextContainerInsets;
    copy.incomingAvatarViewSize = self.incomingAvatarViewSize;
    copy.outgoingAvatarViewSize = self.outgoingAvatarViewSize;
    copy.incomingMediaViewSize = self.incomingMediaViewSize;
    copy.outgoingMediaViewSize = self.outgoingMediaViewSize;
    copy.incomingMessageBubbleAvatarSpacing = self.incomingMessageBubbleAvatarSpacing;
    copy.outgoingMessageBubbleAvatarSpacing = self.outgoingMessageBubbleAvatarSpacing;
    
    copy.slidingTimestampDistance = self.slidingTimestampDistance;
    copy.slidingTimestampAvatarDistance = self.slidingTimestampAvatarDistance;
    
    return copy;
}

@end
