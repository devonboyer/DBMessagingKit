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

#import "MessagingPhotoCell.h"

#import "MessagingCollectionViewLayoutAttributes.h"

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

@interface MessagingPhotoCell () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) MaskedImageView *photoImageView;

@property (assign, nonatomic) CGSize incomingPhotoImageSize;
@property (assign, nonatomic) CGSize outgoingPhotoImageSize;

@end

@implementation MessagingPhotoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.photoImageView = [[MaskedImageView alloc] init];
        [self.photoImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.photoImageView setClipsToBounds:YES];
        [self.photoImageView setUserInteractionEnabled:YES];
        [self.photoImageView setFrame:self.messageBubbleImageView.frame];
        [self.photoImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.messageBubbleImageView addSubview:self.photoImageView];
        
        UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePhotoTap:)];
        [photoTap setDelegate:self];
        [self.photoImageView addGestureRecognizer:photoTap];
    }
    return self;
}

- (void)applyLayoutAttributes:(MessagingCollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    self.incomingPhotoImageSize = layoutAttributes.incomingPhotoImageSize;
    self.outgoingPhotoImageSize = layoutAttributes.outgoingPhotoImageSize;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch (self.type) {
        case IGChatMessageBubbleTypeIncoming: {
            
            CGFloat photoWidth = self.incomingPhotoImageSize.width;
            
            [self.messageBubbleImageView setFrame:CGRectMake(self.incomingAvatarSize.width + self.incomingMessageBubbleAvatarSpacing,
                                                             CGRectGetMaxY(self.messageTopLabel.frame),
                                                             photoWidth,
                                                             CGRectGetHeight(self.frame) - self.cellTopLabelHeight - self.messageTopLabelHeight - self.cellBottomLabelHeight)];
            break;
        }
        case IGChatMessageBubbleTypeOutgoing: {
            
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

- (void)handlePhotoTap:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(messageCell:didTapPhotoImageView:)]) {
        [self.delegate messageCell:self didTapPhotoImageView:self.photoImageView];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}



// TODO: Remove this when confident that MaskedImageView is working properly
#pragma mark - Utility

- (void)applyMask
{
    UIImageView *imageView = self.photoImageView;
    
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[self.messageBubbleImageView.image CGImage];
    mask.frame = imageView.layer.bounds;
    mask.contentsScale = [UIScreen mainScreen].scale;
    mask.contentsCenter = CGRectMake(imageView.center.x/imageView.layer.bounds.size.width,
                                     imageView.center.y/imageView.layer.bounds.size.height,
                                     1.0/imageView.layer.bounds.size.width,
                                     1.0/imageView.layer.bounds.size.height);
    
    self.messageBubbleImageView.layer.mask = mask;
}

@end
