//
//  MessagingCollectionViewDelegateFlowLayout.h
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-10-12.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The 'MessagingCollectionViewDelegateFlowLayout' protocol defines methods that allow you to
 *  manage additional layout information for the collection view and respond to additional actions on its items.
 *  The methods of this protocol are all optional.
 */
@protocol MessagingCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

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
 *  Notifies the delegate that the photo image view at the specified indexPath did receive a tap event.
 *
 *  @param collectionView  The collection view object that is notifying the delegate of the tap event.
 *  @param photoImageView  The photo image view that was tapped.
 *  @param indexPath       The index path of the item for which the photo was tapped.
 */
- (void)collectionView:(UICollectionView *)collectionView didTapPhotoImageView:(UIImageView *)photoImageView atIndexPath:(NSIndexPath *)indexPath;

/**
 *  Notifies the delegate that the message bubble at the specified indexPath did receive a tap event.
 *
 *  @param collectionView The collection view object that is notifying the delegate of the tap event.
 *  @param indexPath      The index path of the item for which the message bubble was tapped.
 *
 *  @discussion A tap event for a message bubble will either mean that a timestamp is being displayed, or just ended
 *  being displayed.
 */
- (void)collectionView:(UICollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath;


@end
