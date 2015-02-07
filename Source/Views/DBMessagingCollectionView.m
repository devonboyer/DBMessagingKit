//
//  DBMessagingCollectionView.m
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

#import "DBMessagingCollectionView.h"

#import "DBMessagingTimestampSupplementaryView.h"
#import "DBMessagingLoadEarlierMessagesHeaderView.h"
#import "DBMessagingTypingIndicatorFooterView.h"

#import "DBMessagingCollectionViewDataSource.h"
#import "DBMessagingCollectionViewDelegateFlowLayout.h"
#import "DBMessagingCollectionViewFlowLayout.h"

NSString * const DBMessagingTextCellIdentifier = @"com.DBMessagingKit.DBMessagingTextCellIdentifier";
NSString * const DBMessagingImageCellIdentifier = @"com.DBMessagingKit.DBMessagingImageCellIdentifier";
NSString * const DBMessagingLocationCellIdentifier = @"com.DBMessagingKit.DBMessagingLocationCellIdentifier";
NSString * const DBMessagingGIFCellIdentifier = @"com.DBMessagingKit.DBMessagingGIFCellIdentifier";
NSString * const DBMessagingMovieCellIdentifier = @"com.DBMessagingKit.DBMessagingMovieCellIdentifier";

NSString * const DBMessagingTimestampSupplementaryViewIdentifier = @"com.DBMessagingKit.DBMessagingimestampSupplementaryViewIdentifier";
NSString * const DBMessagingTypingIndicatorFooterViewIdentifier = @"com.DBMessagingKit.DBMessagingTypingIndicatorFooterViewIdentifier";
NSString * const DBMessagingLoadMoreHeaderViewIdentifier = @"com.DBMessagingKit.DBMessagingLoadMoreHeaderViewIdentifier";

@implementation DBMessagingCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self setup];
        [self registerViews];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self setup];
    [self registerViews];
}

- (void)setup
{
    self.alwaysBounceVertical = YES;
    [self setKeyboardDismissMode:UIScrollViewKeyboardDismissModeInteractive];
}

- (void)registerViews
{
    // Cells
    [self registerClass:[DBMessagingTextCell class] forCellWithReuseIdentifier:DBMessagingTextCellIdentifier];
    [self registerClass:[DBMessagingImageCell class] forCellWithReuseIdentifier:DBMessagingImageCellIdentifier];
    [self registerClass:[DBMessagingLocationCell class] forCellWithReuseIdentifier:DBMessagingLocationCellIdentifier];
    [self registerClass:[DBMessagingGIFCell class] forCellWithReuseIdentifier:DBMessagingGIFCellIdentifier];
    [self registerClass:[DBMessagingMovieCell class] forCellWithReuseIdentifier:DBMessagingMovieCellIdentifier];

    // Supplementary Views
    [self registerClass:[DBMessagingTimestampSupplementaryView class] forSupplementaryViewOfKind:DBMessagingCollectionElementKindTimestamp withReuseIdentifier:DBMessagingTimestampSupplementaryViewIdentifier];
    [self registerClass:[DBMessagingTypingIndicatorFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:DBMessagingTypingIndicatorFooterViewIdentifier];
    [self registerClass:[DBMessagingLoadEarlierMessagesHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DBMessagingLoadMoreHeaderViewIdentifier];
}

- (UICollectionReusableView *)dequeueLoadMoreHeaderViewForIndexPath:(NSIndexPath *)indexPath
{
    DBMessagingLoadEarlierMessagesHeaderView *loadMoreHeaderView = [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                             withReuseIdentifier:DBMessagingLoadMoreHeaderViewIdentifier
                                                                                    forIndexPath:indexPath];
    self.loadMoreHeaderView = loadMoreHeaderView;
    return loadMoreHeaderView;
}

- (UICollectionReusableView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath
{
    DBMessagingTypingIndicatorFooterView *typingIndicatorFooterView = [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                               withReuseIdentifier:DBMessagingTypingIndicatorFooterViewIdentifier
                                                                      forIndexPath:indexPath];
    self.typingIndicatorFooterView = typingIndicatorFooterView;
    return typingIndicatorFooterView;
}

- (UICollectionReusableView *)dequeueTimestampSupplementaryViewForIndexPath:(NSIndexPath *)indexPath
{
    DBMessagingTimestampSupplementaryView *timestampSupplementaryView = [self dequeueReusableSupplementaryViewOfKind:DBMessagingCollectionElementKindTimestamp withReuseIdentifier:DBMessagingTimestampSupplementaryViewIdentifier forIndexPath:indexPath];
    return timestampSupplementaryView;
}

#pragma mark - MessagingParentCellDelegate

- (void)messageCell:(DBMessagingParentCell *)cell didTapAvatarImageView:(UIImageView *)avatarImageView
{
    [self.delegate collectionView:self
            didTapAvatarImageView:avatarImageView
                      atIndexPath:[self indexPathForCell:cell]];
}

- (void)messageCell:(DBMessagingParentCell *)cell didTapImageView:(UIImageView *)imageView
{
    [self.delegate collectionView:self
             didTapImageView:imageView
                      atIndexPath:[self indexPathForCell:cell]];
}

- (void)messageCell:(DBMessagingParentCell *)cell didTapMessageBubbleImageView:(UIImageView *)messageBubbleImageView
{
    [self.delegate collectionView:self
     didTapMessageBubbleImageView:messageBubbleImageView
                      atIndexPath:[self indexPathForCell:cell]];
}

- (void)messageCell:(DBMessagingParentCell *)cell didTapMoviePlayer:(MPMoviePlayerController *)moviePlayer
{
    [self.delegate collectionView:self
                didTapMoviePlayer:moviePlayer
                      atIndexPath:[self indexPathForCell:cell]];
}

@end
