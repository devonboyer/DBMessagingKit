//
//  DBMessagingCollectionViewHiddenTimestampFlowLayout.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2015-02-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingCollectionViewBaseFlowLayout.h"

@class DBMessagingCollectionView;

/*!
 *  The 'DBMessagingCollectionViewHiddenTimestampFlowLayout' extends a 'DBMessagingCollectionViewBaseFlowLayout' to provide
 *  support for hidden timestamps that are displayed by setting the 'tappedIndexPath'. 
 *
 *  @discussion The 'DBMessagingCollectionViewHiddenTimestampFlowLayout' displays timestamps below a message when tapped similar
 *  to Facebook Messenger.
 *
 *  @see DBMessagingCollectionViewBaseFlowLayout
 */
@interface DBMessagingCollectionViewHiddenTimestampFlowLayout : DBMessagingCollectionViewBaseFlowLayout

/**
 *  Specifies the indexPath that recieved a tap event in order to display or hide a 'MessagingTimestampSupplementaryView'.
 */
@property (strong, nonatomic) NSIndexPath *tappedIndexPath;

/**
 *  Specifies the padding that should be applied to the 'MessagingTimestampSupplementaryView'.
 *
 *  @discussion The 'timestampSupplementaryView' height is calculated using the boundingBox of the attributed string
 *  passed by the appropriate dataSource method.
 */
@property (assign, nonatomic) CGFloat timestampSupplementaryViewPadding;

@end
