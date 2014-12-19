//
//  MessagingPhotoCell.m
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-10-09.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingImageCell.h"
#import "MessagingCollectionViewLayoutAttributes.h"
#import "UIColor+Messaging.h"

@interface MaskedImageView : UIImageView

@end

@implementation MaskedImageView

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    [self applyMask];
}

#pragma mark - Utility

- (void)applyMask
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *maskImage = ((UIImageView *)self.superview).image;
        
        CALayer *mask = [CALayer layer];
        mask.contents = (id)[maskImage CGImage];
        mask.frame = self.layer.bounds;
        mask.contentsScale = [UIScreen mainScreen].scale;
        mask.contentsCenter = CGRectMake(self.center.x/self.layer.bounds.size.width,
                                         self.center.y/self.layer.bounds.size.height,
                                         1.0/self.layer.bounds.size.width,
                                         1.0/self.layer.bounds.size.height);
        
        self.superview.layer.mask = mask;
    });
}

@end

@interface MessagingImageCell () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) MaskedImageView *imageView;

@property (assign, nonatomic) CGSize incomingPhotoImageSize;
@property (assign, nonatomic) CGSize outgoingPhotoImageSize;

@end

@implementation MessagingImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[MaskedImageView alloc] init];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.imageView setClipsToBounds:YES];
        [self.imageView setUserInteractionEnabled:YES];
        [self.imageView setFrame:self.messageBubbleImageView.frame];
        [self.imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.imageView setBackgroundColor:[UIColor clearColor]];
        [self.imageView setImage:nil]; // create an initial mask
        [self.messageBubbleImageView addSubview:self.imageView];
        
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
        [imageTap setDelegate:self];
        [self.imageView addGestureRecognizer:imageTap];
    }
    return self;
}

- (void)applyLayoutAttributes:(MessagingCollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    self.incomingPhotoImageSize = layoutAttributes.incomingImageSize;
    self.outgoingPhotoImageSize = layoutAttributes.outgoingImageSize;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch (self.type) {
        case MessageBubbleTypeIncoming: {
            
            CGFloat photoWidth = self.incomingPhotoImageSize.width;
            
            [self.messageBubbleImageView setFrame:CGRectMake(self.incomingAvatarSize.width + self.incomingMessageBubbleAvatarSpacing,
                                                             CGRectGetMaxY(self.messageTopLabel.frame),
                                                             photoWidth,
                                                             CGRectGetHeight(self.frame) - self.cellTopLabelHeight - self.messageTopLabelHeight - self.cellBottomLabelHeight)];
            break;
        }
        case MessageBubbleTypeOutgoing: {
            
            CGFloat photoWidth = self.outgoingPhotoImageSize.width;
            
            [self.messageBubbleImageView setFrame:CGRectMake(CGRectGetWidth(self.frame) - photoWidth - self.outgoingAvatarSize.width - self.outgoingMessageBubbleAvatarSpacing,
                                                             CGRectGetMaxY(self.messageTopLabel.frame),
                                                             photoWidth,
                                                             CGRectGetHeight(self.frame) - self.cellTopLabelHeight - self.messageTopLabelHeight - self.cellBottomLabelHeight)];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Actions

- (void)handleImageTap:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(messageCell:didTapImageView:)]) {
        [self.delegate messageCell:self didTapImageView:self.imageView];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
