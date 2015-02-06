//
//  MessagingParentCell.h
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-09-17.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessagingParentCell;

typedef NS_ENUM(NSInteger, MessageBubbleType) {
    MessageBubbleTypeOutgoing,
    MessageBubbleTypeIncoming
};

@protocol MessagingParentCellDelegate <NSObject>

@optional
- (void)messageCell:(MessagingParentCell *)cell didTapAvatarImageView:(UIImageView *)avatarImageView;

@end

@interface MessagingParentCell : UICollectionViewCell

@property (weak, nonatomic) id <MessagingParentCellDelegate> delegate;
@property (weak, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) UILabel *messageTopLabel;
@property (strong, nonatomic) UILabel *cellTopLabel;
@property (strong, nonatomic) UILabel *cellBottomLabel;
@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UIImageView *accessoryImageView;
@property (strong, nonatomic) UIImageView *messageBubbleImageView;
@property (assign, nonatomic) MessageBubbleType type;
@property (assign, nonatomic) BOOL hideAvatar;

@property (assign, nonatomic) CGSize incomingAvatarSize;
@property (assign, nonatomic) CGSize outgoingAvatarSize;
@property (assign, nonatomic) CGFloat messageTopLabelHeight;
@property (assign, nonatomic) CGFloat cellTopLabelHeight;
@property (assign, nonatomic) CGFloat cellBottomLabelHeight;
@property (assign, nonatomic) CGFloat messageBubbleLeftRightMargin;
@property (assign, nonatomic) CGFloat incomingMessageBubbleAvatarSpacing;
@property (assign, nonatomic) CGFloat outgoingMessageBubbleAvatarSpacing;
@property (assign, nonatomic) UIEdgeInsets messageBubbleTextContainerInsets;

@end
