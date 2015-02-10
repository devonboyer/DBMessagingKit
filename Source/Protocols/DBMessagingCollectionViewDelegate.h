//
//  DBMessagingCollectionViewDelegate.h
//  DBMessagingKit
//
//  Created by Devon Boyer on 2015-02-09.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMessagingMediaView;

/**
 *  The 'DBMessagingCollectionViewDelegateFlowLayout' protocol defines methods that allow you to respond to additional 
 *  actions on its items.
 */
@protocol DBMessagingCollectionViewDelegate <UICollectionViewDelegate>

@optional

/**
 *  Notifies the delegate that the avatar image view at the specified indexPath did receive a tap event.
 *
 *  @param collectionView  The collection view object that is notifying the delegate of the tap event.
 *  @param avatarImageView The avatar image view that was tapped.
 *  @param indexPath       The index path of the item for which the avatar was tapped.
 */
- (void)collectionView:(UICollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath;

/**
 *  Notifies the delegate that the image view at the specified indexPath did receive a tap event.
 *
 *  @param collectionView  The collection view object that is notifying the delegate of the tap event.
 *  @param imageView  The image view that was tapped.
 *  @param indexPath       The index path of the item for which the photo was tapped.
 */
- (void)collectionView:(UICollectionView *)collectionView didTapMediaView:(DBMessagingMediaView *)mediaView atIndexPath:(NSIndexPath *)indexPath;

/**
 *  Notifies the delegate that the message bubble at the specified indexPath did receive a tap event.
 *
 *  @param collectionView          The collection view object that is notifying the delegate of the tap event.
 *  @param messageBubbleImageView  The message bubble image view that was tapped.
 *  @param indexPath               The index path of the item for which the message bubble was tapped.
 *
 *  @discussion A tap event for a message bubble will either mean that a timestamp is being displayed, or just ended
 *  being displayed.
 */
- (void)collectionView:(UICollectionView *)collectionView didTapMessageBubbleImageView:(UIImageView *)messageBubbleImageView atIndexPath:(NSIndexPath *)indexPath;

@end
