//
//  MessagingCollectionView.m
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-09-21.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingCollectionView.h"

#import "MessagingTimestampSupplementaryView.h"
#import "MessagingLoadEarlierMessagesHeaderView.h"
#import "MessagingTypingIndicatorFooterView.h"

#import "MessagingCollectionViewDataSource.h"
#import "MessagingCollectionViewDelegateFlowLayout.h"
#import "MessagingCollectionViewFlowLayout.h"

NSString * const kMessagingTextCellIdentifier = @"kMessagingTextCellIdentifier";
NSString * const kMessagingImageCellIdentifier = @"kMessagingImageCellIdentifier";
NSString * const kMessagingLocationCellIdentifier = @"kMessagingLocationCellIdentifier";
NSString * const kMessagingGIFCellIdentifier = @"kMessagingGIFCellIdentifier";

NSString * const kMessagingimestampSupplementaryViewIdentifier = @"kMessagingimestampSupplementaryViewIdentifier";
NSString * const kMessagingTypingIndicatorFooterViewIdentifier = @"kMessagingTypingIndicatorFooterViewIdentifier";
NSString * const kMessagingLoadMoreHeaderViewIdentifier = @"kMessagingLoadMoreHeaderViewIdentifier";

@implementation MessagingCollectionView

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
    [self registerClass:[MessagingTextCell class] forCellWithReuseIdentifier:kMessagingTextCellIdentifier];
    [self registerClass:[MessagingImageCell class] forCellWithReuseIdentifier:kMessagingImageCellIdentifier];
    [self registerClass:[MessagingLocationCell class] forCellWithReuseIdentifier:kMessagingLocationCellIdentifier];
    [self registerClass:[MessagingGIFCell class] forCellWithReuseIdentifier:kMessagingGIFCellIdentifier];
    
    // Supplementary Views
    [self registerClass:[MessagingTimestampSupplementaryView class] forSupplementaryViewOfKind:MessagingCollectionElementKindTimestamp withReuseIdentifier:kMessagingimestampSupplementaryViewIdentifier];
    [self registerClass:[MessagingTypingIndicatorFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kMessagingTypingIndicatorFooterViewIdentifier];
    [self registerClass:[MessagingLoadEarlierMessagesHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMessagingLoadMoreHeaderViewIdentifier];
}

- (UICollectionReusableView *)dequeueLoadMoreHeaderViewForIndexPath:(NSIndexPath *)indexPath
{
    MessagingLoadEarlierMessagesHeaderView *loadMoreHeaderView = [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                             withReuseIdentifier:kMessagingLoadMoreHeaderViewIdentifier
                                                                                    forIndexPath:indexPath];
    self.loadMoreHeaderView = loadMoreHeaderView;
    return loadMoreHeaderView;
}

- (UICollectionReusableView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath
{
    MessagingTypingIndicatorFooterView *typingIndicatorFooterView = [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                               withReuseIdentifier:kMessagingTypingIndicatorFooterViewIdentifier
                                                                      forIndexPath:indexPath];
    self.typingIndicatorFooterView = typingIndicatorFooterView;
    return typingIndicatorFooterView;
}

- (UICollectionReusableView *)dequeueTimestampSupplementaryViewForIndexPath:(NSIndexPath *)indexPath
{
    MessagingTimestampSupplementaryView *timestampSupplementaryView = [self dequeueReusableSupplementaryViewOfKind:MessagingCollectionElementKindTimestamp withReuseIdentifier:kMessagingimestampSupplementaryViewIdentifier forIndexPath:indexPath];
    return timestampSupplementaryView;
}

#pragma mark - MessagingParentCellDelegate

- (void)messageCell:(MessagingParentCell *)cell didTapAvatarImageView:(UIImageView *)avatarImageView
{
    [self.delegate collectionView:self
            didTapAvatarImageView:avatarImageView
                      atIndexPath:[self indexPathForCell:cell]];
}

- (void)messageCell:(MessagingParentCell *)cell didTapImageView:(UIImageView *)imageView
{
    [self.delegate collectionView:self
             didTapImageView:imageView
                      atIndexPath:[self indexPathForCell:cell]];
}

- (void)messageCell:(MessagingParentCell *)cell didTapMessageBubbleImageView:(UIImageView *)messageBubbleImageView
{
    [self.delegate collectionView:self
     didTapMessageBubbleImageView:messageBubbleImageView
                      atIndexPath:[self indexPathForCell:cell]];
}

@end
