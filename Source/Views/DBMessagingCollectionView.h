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
#import "DBMessagingMediaCell.h"
#import "DBMessagingCollectionViewBaseFlowLayout.h"

#import "DBMessagingCollectionViewDelegate.h"
#import "DBMessagingCollectionViewDataSource.h"
#import "DBMessagingCollectionViewDelegateFlowLayout.h"

@class DBMessagingLoadEarlierMessagesHeaderView;
@class DBMessagingTypingIndicatorFooterView;
@class DBMessagingTimestampSupplementaryView;

@interface DBMessagingCollectionView : UICollectionView <DBMessagingTextCellDelegate, DBMessagingMediaCellDelegate>

@property (weak, nonatomic) id <DBMessagingCollectionViewDataSource> dataSource;
@property (weak, nonatomic) id <DBMessagingCollectionViewDelegate, DBMessagingCollectionViewDelegateFlowLayout> delegate;
@property (strong, nonatomic) DBMessagingCollectionViewBaseFlowLayout *collectionViewLayout;

@property (weak, nonatomic) DBMessagingLoadEarlierMessagesHeaderView *loadMoreHeaderView;
@property (weak, nonatomic) DBMessagingTypingIndicatorFooterView *typingIndicatorFooterView;

- (DBMessagingLoadEarlierMessagesHeaderView *)dequeueLoadEarlierMessagesHeaderViewForIndexPath:(NSIndexPath *)indexPath;
- (DBMessagingTypingIndicatorFooterView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath;
- (DBMessagingTimestampSupplementaryView *)dequeueTimestampSupplementaryViewForIndexPath:(NSIndexPath *)indexPath;

@end
