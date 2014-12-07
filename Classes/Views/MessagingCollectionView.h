//
//  MessagingCollectionView.h
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-09-21.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MessagingTextCell.h"
#import "MessagingPhotoCell.h"
#import "MessagingLocationCell.h"
#import "MessagingCollectionViewDataSource.h"
#import "MessagingCollectionViewDelegateFlowLayout.h"
#import "MessagingCollectionViewFlowLayout.h"

@class MessagingCollectionViewFlowLayout;
@class MessagingLoadEarlierMessagesHeaderView;
@class MessagingTypingIndicatorFooterView;

// Cells
extern NSString * const kMessagingTextCellIdentifier;
extern NSString * const kMessagingPhotoCellIdentifier;
extern NSString * const kMessagingLocationCellIdentifier;

// Supplementary Views
extern NSString * const kMessagingimestampSupplementaryViewIdentifier;
extern NSString * const kMessagingTypingIndicatorFooterViewIdentifier;
extern NSString * const kMessagingLoadMoreHeaderViewIdentifier;

@interface MessagingCollectionView : UICollectionView <MessagingPhotoCellDelegate, MessagingTextCellDelegate>

@property (weak, nonatomic) id <MessagingCollectionViewDataSource> dataSource;
@property (weak, nonatomic) id <MessagingCollectionViewDelegateFlowLayout> delegate;
@property (strong, nonatomic) MessagingCollectionViewFlowLayout *collectionViewLayout;

@property (strong, nonatomic) MessagingLoadEarlierMessagesHeaderView *loadMoreHeaderView;
@property (strong, nonatomic) MessagingTypingIndicatorFooterView *typingIndicatorFooterView;

- (UICollectionReusableView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath;
- (UICollectionReusableView *)dequeueLoadMoreHeaderViewForIndexPath:(NSIndexPath *)indexPath;
- (UICollectionReusableView *)dequeueTimestampSupplementaryViewForIndexPath:(NSIndexPath *)indexPath;

@end