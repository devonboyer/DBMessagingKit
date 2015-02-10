//
//  DBMessagingParentCell.h
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

#import <UIKit/UIKit.h>

@class DBMessagingParentCell;

typedef NS_ENUM(NSInteger, MessageBubbleType) {
    MessageBubbleTypeOutgoing,
    MessageBubbleTypeIncoming
};

@protocol DBMessagingParentCellDelegate <NSObject>

@optional
- (void)messageCell:(DBMessagingParentCell *)cell didTapAvatarImageView:(UIImageView *)avatarImageView;

@end

@interface DBMessagingParentCell : UICollectionViewCell

+ (NSString *)mimeType;

+ (NSString *)cellReuseIdentifier;

@property (weak, nonatomic) id <DBMessagingParentCellDelegate> delegate;
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
