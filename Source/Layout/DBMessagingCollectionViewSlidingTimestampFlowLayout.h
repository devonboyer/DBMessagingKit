//
//  DBMessagingCollectionViewSlidingTimestampFlowLayout.h
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

/*!
 *  The 'DBMessagingCollectionViewSlidingTimestampFlowLayout' extends a 'DBMessagingCollectionViewBaseFlowLayout' to provide
 *  support for sliding timestamps that are displayed by setting the 'tappedIndexPath'.
 *
 *  @discussion The 'DBMessagingCollectionViewSlidingTimestampFlowLayout' displays timestamps on the right-hand side of a 
 *  message by pulling in the horizontally similar to iMessage.
 *
 *  @see DBMessagingCollectionViewBaseFlowLayout
 */
@interface DBMessagingCollectionViewSlidingTimestampFlowLayout : DBMessagingCollectionViewBaseFlowLayout

@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;

@property (assign, nonatomic) BOOL panning;
@property (assign, nonatomic) CGPoint panLocation;
@property (assign, nonatomic) CGPoint startLocation;

@end
