//
//  DBMessagingTimestampSupplementaryView.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-10-11.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingTimestampSupplementaryView.h"
#import "DBMessagingCollectionViewLayoutAttributes.h"

@interface DBMessagingTimestampSupplementaryView ()

@property (assign, nonatomic) CGFloat messageBubbleTopLabelHeight;
@property (assign, nonatomic) CGFloat cellTopLabelHeight;
@property (assign, nonatomic) CGSize incomingAvatarSize;
@property (assign, nonatomic) CGSize outgoingAvatarSize;
@property (assign, nonatomic) UIEdgeInsets messageBubbleTextContainerInsets;

@property (strong, nonatomic) UILabel *timestampLabel;

@end

@implementation DBMessagingTimestampSupplementaryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _timestampLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [_timestampLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_timestampLabel setTextAlignment:NSTextAlignmentCenter];
        [_timestampLabel setNumberOfLines:1];
        [self addSubview:_timestampLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch (_timestampStyle) {
        case DBMessagingTimestampStyleHidden: {
            
            switch (self.type) {
                case MessageBubbleTypeIncoming: {
                    [self.timestampLabel setTextAlignment:NSTextAlignmentLeft];
                    
                    [_timestampLabel setFrame:CGRectMake(self.incomingAvatarSize.width + self.messageBubbleTextContainerInsets.right + self.messageBubbleTextContainerInsets.left, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
                    break;
                }
                case MessageBubbleTypeOutgoing: {
                    [self.timestampLabel setTextAlignment:NSTextAlignmentRight];

                    [_timestampLabel setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds) - self.outgoingAvatarSize.width - self.messageBubbleTextContainerInsets.right - self.messageBubbleTextContainerInsets.left, CGRectGetHeight(self.bounds))];
                    break;
                }
            }
            
            break;
        }
        case DBMessagingTimestampStyleSliding: {
            [self.timestampLabel setTextAlignment:NSTextAlignmentLeft];
            
            CGFloat relativeHeight = self.bounds.size.height + _messageBubbleTopLabelHeight + _cellTopLabelHeight;
            
            CGSize timestampLabelSize = [_timestampLabel sizeThatFits:self.bounds.size];
            [_timestampLabel setFrame:CGRectMake(0, 0, self.bounds.size.width, timestampLabelSize.height)];
            [_timestampLabel setCenter:CGPointMake(_timestampLabel.center.x, relativeHeight / 2.0)];
            break;
        }
        default:
            break;
    }

}

- (void)applyLayoutAttributes:(DBMessagingCollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    self.incomingAvatarSize = layoutAttributes.incomingAvatarViewSize;
    self.outgoingAvatarSize = layoutAttributes.outgoingAvatarViewSize;
    self.messageBubbleTextContainerInsets = layoutAttributes.messageBubbleTextViewTextContainerInsets;
    self.messageBubbleTopLabelHeight = layoutAttributes.messageBubbleTopLabelHeight;
    self.cellTopLabelHeight = layoutAttributes.cellTopLabelHeight;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.timestampLabel.text = @"";
    self.timestampLabel.attributedText = nil;
}

@end
