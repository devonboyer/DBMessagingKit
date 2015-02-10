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

#import "DBMessagingCollectionViewDataSource.h"
#import "DBMessagingCollectionViewDelegateFlowLayout.h"
#import "DBMessagingCollectionViewBaseFlowLayout.h"
#import "DBMessagingCollectionViewHiddenTimestampFlowLayout.h"
#import "DBMessagingCollectionViewSlidingTimestampFlowLayout.h"

#import "DBMessagingImageMediaCell.h"
#import "DBMessagingVideoMediaCell.h"
#import "DBMessagingLocationMediaCell.h"
#import "DBMessagingTimestampSupplementaryView.h"
#import "DBMessagingLoadEarlierMessagesHeaderView.h"
#import "DBMessagingTypingIndicatorFooterView.h"

@implementation DBMessagingCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.alwaysBounceVertical = YES;
    [self setKeyboardDismissMode:UIScrollViewKeyboardDismissModeInteractive];

    [self registerClass:[DBMessagingTextCell class] forCellWithReuseIdentifier:[DBMessagingTextCell cellReuseIdentifier]];
    [self registerClass:[DBMessagingImageMediaCell class] forCellWithReuseIdentifier:[DBMessagingImageMediaCell cellReuseIdentifier]];
    [self registerClass:[DBMessagingVideoMediaCell class] forCellWithReuseIdentifier:[DBMessagingVideoMediaCell cellReuseIdentifier]];
    [self registerClass:[DBMessagingLocationMediaCell class] forCellWithReuseIdentifier:[DBMessagingLocationMediaCell cellReuseIdentifier]];

    [self registerClass:[DBMessagingTimestampSupplementaryView class] forSupplementaryViewOfKind:DBMessagingCollectionElementKindTimestamp withReuseIdentifier:[DBMessagingTimestampSupplementaryView viewReuseIdentifier]];
    [self registerClass:[DBMessagingTypingIndicatorFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:[DBMessagingTypingIndicatorFooterView viewReuseIdentifier]];
    [self registerClass:[DBMessagingLoadEarlierMessagesHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[DBMessagingLoadEarlierMessagesHeaderView viewReuseIdentifier]];
}

- (DBMessagingLoadEarlierMessagesHeaderView *)dequeueLoadEarlierMessagesHeaderViewForIndexPath:(NSIndexPath *)indexPath {
    
    DBMessagingLoadEarlierMessagesHeaderView *loadMoreHeaderView =
    [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                              withReuseIdentifier:[DBMessagingLoadEarlierMessagesHeaderView viewReuseIdentifier]
                                     forIndexPath:indexPath];
    
    self.loadMoreHeaderView = loadMoreHeaderView;
    return loadMoreHeaderView;
}

- (DBMessagingTypingIndicatorFooterView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath {
    
    DBMessagingTypingIndicatorFooterView *typingIndicatorFooterView =
    [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                              withReuseIdentifier:[DBMessagingTypingIndicatorFooterView viewReuseIdentifier]
                                     forIndexPath:indexPath];
    
    self.typingIndicatorFooterView = typingIndicatorFooterView;
    return typingIndicatorFooterView;
}

- (DBMessagingTimestampSupplementaryView *)dequeueTimestampSupplementaryViewForIndexPath:(NSIndexPath *)indexPath {
    
    DBMessagingTimestampSupplementaryView *timestampSupplementaryView =
    [self dequeueReusableSupplementaryViewOfKind:DBMessagingCollectionElementKindTimestamp
                             withReuseIdentifier:[DBMessagingTimestampSupplementaryView viewReuseIdentifier]
                                    forIndexPath:indexPath];
    return timestampSupplementaryView;
}

#pragma mark - DBMessagingParentCellDelegate

- (void)messageCell:(DBMessagingParentCell *)cell didTapAvatarImageView:(UIImageView *)avatarImageView
{
    if ([self.delegate respondsToSelector:@selector(collectionView:didTapAvatarImageView:atIndexPath:)]) {
        
        [self.delegate collectionView:self
                didTapAvatarImageView:avatarImageView
                          atIndexPath:[self indexPathForCell:cell]];
    }
}

- (void)messageCell:(DBMessagingParentCell *)cell didTapMediaView:(DBMessagingMediaView *)mediaView
{
    if ([self.delegate respondsToSelector:@selector(collectionView:didTapMediaView:atIndexPath:)]) {
        
        [self.delegate collectionView:self
                      didTapMediaView:mediaView
                          atIndexPath:[self indexPathForCell:cell]];
    }
}

- (void)messageCell:(DBMessagingParentCell *)cell didTapMessageBubbleImageView:(UIImageView *)messageBubbleImageView
{
    if ([self.delegate respondsToSelector:@selector(collectionView:didTapMessageBubbleImageView:atIndexPath:)]) {
        
        [self.delegate collectionView:self
         didTapMessageBubbleImageView:messageBubbleImageView
                          atIndexPath:[self indexPathForCell:cell]];
    }
}

@end
