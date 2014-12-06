//
//  MessagingCollectionViewFlowLayout.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-09-19.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const MessagingCollectionElementKindTimestamp;

@class MessagingCollectionView;

@interface MessagingCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (strong, nonatomic, readonly) MessagingCollectionView *collectionView;
@property (strong, nonatomic) NSIndexPath *tappedIndexPath;
@property (assign, nonatomic, readonly) CGFloat itemWidth;
@property (assign, nonatomic) BOOL springinessEnabled;
@property (assign, nonatomic) CGFloat scrollResistanceFactor;
@property (assign, nonatomic) CGFloat cellTopLabelPadding;
@property (assign, nonatomic) CGFloat messageTopLabelPadding;
@property (assign, nonatomic) CGFloat cellBottomLabelPadding;
@property (assign, nonatomic) CGFloat timestampSupplementaryViewPadding;

@property (assign, nonatomic) CGSize incomingAvatarViewSize;
@property (assign, nonatomic) CGSize outgoingAvatarViewSize;
@property (assign, nonatomic) CGSize incomingPhotoImageSize;
@property (assign, nonatomic) CGSize outgoingPhotoImageSize;
@property (assign, nonatomic) CGFloat messageBubbleLeftRightMargin;
@property (assign, nonatomic) CGFloat incomingMessageBubbleAvatarSpacing;
@property (assign, nonatomic) CGFloat outgoingMessageBubbleAvatarSpacing;
@property (strong, nonatomic) UIFont *messageBubbleFont;
@property (assign, nonatomic) UIEdgeInsets messageBubbleTextViewTextContainerInsets;
@property (assign, nonatomic) CGFloat inOutMessageBubbleInteritemSpacing;

- (CGSize)sizeForCellAtIndexPath:(NSIndexPath *)indexPath;

@end
