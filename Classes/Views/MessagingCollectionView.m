//
//  MessagingCollectionView.m
//  MessagingKit
//
//  Created by Devon Boyer on 2014-09-21.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingCollectionView.h"



#import "MessagingTimestampSupplementaryView.h"
#import "MessagingLoadEarlierMessagesHeaderView.h"
#import "MessagingTypingIndicatorFooterView.h"

NSString * const kChatTextCellIdentifier = @"kChatTextCellIdentifier";
NSString * const kChatPhotoCellIdentifier = @"kChatPhotoCellIdentifier";

NSString * const kChatTimestampSupplementaryViewIdentifier = @"kChatTimestampSupplementaryViewIdentifier";
NSString * const kChatTypingIndicatorFooterViewIdentifier = @"kChatTypingIndicatorFooterViewIdentifier";
NSString * const kChatLoadMoreHeaderViewIdentifier = @"kChatLoadMoreHeaderViewIdentifier";

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
    [self registerClass:[MessagingTextCell class] forCellWithReuseIdentifier:kChatTextCellIdentifier];
    [self registerClass:[MessagingPhotoCell class] forCellWithReuseIdentifier:kChatPhotoCellIdentifier];
    
    // Supplementary Views
    [self registerClass:[MessagingTimestampSupplementaryView class] forSupplementaryViewOfKind:IGMessagingCollectionElementKindTimestamp withReuseIdentifier:kChatTimestampSupplementaryViewIdentifier];
    [self registerClass:[MessagingTypingIndicatorFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kChatTypingIndicatorFooterViewIdentifier];
    [self registerClass:[MessagingLoadEarlierMessagesHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kChatLoadMoreHeaderViewIdentifier];
}

- (UICollectionReusableView *)dequeueLoadMoreHeaderViewForIndexPath:(NSIndexPath *)indexPath
{
    MessagingLoadEarlierMessagesHeaderView *loadMoreHeaderView = [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                             withReuseIdentifier:kChatLoadMoreHeaderViewIdentifier
                                                                                    forIndexPath:indexPath];
    self.loadMoreHeaderView = loadMoreHeaderView;
    return loadMoreHeaderView;
}

- (UICollectionReusableView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath
{
    MessagingTypingIndicatorFooterView *typingIndicatorFooterView = [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                               withReuseIdentifier:kChatTypingIndicatorFooterViewIdentifier
                                                                      forIndexPath:indexPath];
    self.typingIndicatorFooterView = typingIndicatorFooterView;
    return typingIndicatorFooterView;
}

- (UICollectionReusableView *)dequeueTimestampSupplementaryViewForIndexPath:(NSIndexPath *)indexPath
{
    MessagingTimestampSupplementaryView *timestampSupplementaryView = [self dequeueReusableSupplementaryViewOfKind:IGMessagingCollectionElementKindTimestamp withReuseIdentifier:kChatTimestampSupplementaryViewIdentifier forIndexPath:indexPath];
    return timestampSupplementaryView;
}

#pragma mark - ChatCollectionViewCellDelegate

- (void)messageCell:(MessagingParentCell *)cell didTapAvatarImageView:(UIImageView *)avatarImageView
{
    [self.delegate collectionView:self
            didTapAvatarImageView:avatarImageView
                      atIndexPath:[self indexPathForCell:cell]];
}

- (void)messageCell:(MessagingParentCell *)cell didTapPhotoImageView:(UIImageView *)photoImageView
{
    [self.delegate collectionView:self
            didTapPhotoImageView:photoImageView
                      atIndexPath:[self indexPathForCell:cell]];
}

- (void)messageCellDidTapMessageBubble:(MessagingParentCell *)cell
{
    [self.delegate collectionView:self didTapMessageBubbleAtIndexPath:[self indexPathForCell:cell]];
}

@end
