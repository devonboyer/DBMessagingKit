//
//  DBMessagingCollectionView.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-21.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

#import "DBMessagingTextCell.h"
#import "DBMessagingImageCell.h"
#import "DBMessagingLocationCell.h"
#import "DBMessagingMovieCell.h"
#import "DBMessagingGIFCell.h"
#import "DBMessagingCollectionViewDataSource.h"
#import "DBMessagingCollectionViewDelegateFlowLayout.h"
#import "DBMessagingCollectionViewBaseFlowLayout.h"

@class DBMessagingCollectionViewBaseFlowLayout;
@class DBMessagingLoadEarlierMessagesHeaderView;
@class DBMessagingTypingIndicatorFooterView;
@class DBMessagingTimestampSupplementaryView;

// Cells
extern NSString * const DBMessagingTextCellIdentifier;
extern NSString * const DBMessagingImageCellIdentifier;
extern NSString * const DBMessagingLocationCellIdentifier;
extern NSString * const DBMessagingGIFCellIdentifier;
extern NSString * const DBMessagingMovieCellIdentifier;

// Supplementary Views
extern NSString * const DBMessagingTimestampSupplementaryViewIdentifier;
extern NSString * const DBMessagingTypingIndicatorFooterViewIdentifier;
extern NSString * const DBMessagingLoadMoreHeaderViewIdentifier;

@interface DBMessagingCollectionView : UICollectionView <DBMessagingImageCellDelegate, DBMessagingTextCellDelegate, DBMessagingMovieCellDelegate>

@property (weak, nonatomic) id <DBMessagingCollectionViewDataSource> dataSource;
@property (weak, nonatomic) id <DBMessagingCollectionViewDelegateFlowLayout> delegate;
@property (strong, nonatomic) DBMessagingCollectionViewBaseFlowLayout *collectionViewLayout;

@property (strong, nonatomic) DBMessagingLoadEarlierMessagesHeaderView *loadMoreHeaderView;
@property (strong, nonatomic) DBMessagingTypingIndicatorFooterView *typingIndicatorFooterView;

- (UICollectionReusableView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath;
- (UICollectionReusableView *)dequeueLoadMoreHeaderViewForIndexPath:(NSIndexPath *)indexPath;
- (DBMessagingTimestampSupplementaryView *)dequeueTimestampSupplementaryViewForIndexPath:(NSIndexPath *)indexPath;

@end
