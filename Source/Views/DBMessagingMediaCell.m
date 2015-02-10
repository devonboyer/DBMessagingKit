//
//  DBMessagingMediaCell.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-10-09.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingMediaCell.h"
#import "DBMessagingCollectionViewLayoutAttributes.h"
#import "UIColor+Messaging.h"

@interface DBMessagingMediaCell () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UITapGestureRecognizer *mediaTap;

@property (assign, nonatomic) CGSize incomingImageSize;
@property (assign, nonatomic) CGSize outgoingImageSize;

@end

@implementation DBMessagingMediaCell

+ (NSString *)cellReuseIdentifier {
    NSAssert(false, @"%s must be overridden by subclass", __PRETTY_FUNCTION__);
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mediaTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMediaTap:)];
        [_mediaTap setDelegate:self];
    }
    return self;
}

- (void)applyLayoutAttributes:(DBMessagingCollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    self.incomingImageSize = layoutAttributes.incomingImageSize;
    self.outgoingImageSize = layoutAttributes.outgoingImageSize;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch (self.type) {
        case MessageBubbleTypeIncoming: {
            
            CGFloat imageWidth = self.incomingImageSize.width;
            
            [self.messageBubbleImageView setFrame:CGRectMake(self.incomingAvatarSize.width + self.incomingMessageBubbleAvatarSpacing,
                                                             CGRectGetMaxY(self.messageTopLabel.frame),
                                                             imageWidth,
                                                             CGRectGetHeight(self.frame) - self.cellTopLabelHeight - self.messageTopLabelHeight - self.cellBottomLabelHeight)];
            break;
        }
        case MessageBubbleTypeOutgoing: {
            
            CGFloat imageWidth = self.outgoingImageSize.width;
            
            [self.messageBubbleImageView setFrame:CGRectMake(CGRectGetWidth(self.frame) - imageWidth - self.outgoingAvatarSize.width - self.outgoingMessageBubbleAvatarSpacing,
                                                             CGRectGetMaxY(self.messageTopLabel.frame),
                                                             imageWidth,
                                                             CGRectGetHeight(self.frame) - self.cellTopLabelHeight - self.messageTopLabelHeight - self.cellBottomLabelHeight)];
            break;
        }
        default:
            break;
    }
    
    [self applyMask];
}

#pragma mark - Setters 

- (void)setMediaView:(UIView *)mediaView {
    
    _mediaView = mediaView;
    [_mediaView addGestureRecognizer:_mediaTap];
}

#pragma mark - Actions

- (void)handleMediaTap:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(messageCell:didTapMediaView:)]) {
        [self.delegate messageCell:self didTapMediaView:_mediaView];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Utility

- (void)applyMask {
    
    CALayer *maskingLayer = _mediaView.layer;
    CGPoint center = _mediaView.center;
    
    UIImage *maskImage = self.messageBubbleImageView.image;
    
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[maskImage CGImage];
    mask.frame = maskingLayer.bounds;
    mask.contentsScale = [UIScreen mainScreen].scale;
    mask.contentsCenter = CGRectMake(center.x/maskingLayer.bounds.size.width,
                                     center.y/maskingLayer.bounds.size.height,
                                     1.0/maskingLayer.bounds.size.width,
                                     1.0/maskingLayer.bounds.size.height);
    
    self.messageBubbleImageView.layer.mask = mask;
}

@end
