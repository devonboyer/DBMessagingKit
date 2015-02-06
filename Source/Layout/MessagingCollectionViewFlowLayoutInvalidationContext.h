//
//  MessagingCollectionViewFlowLayoutInvalidationContext.h
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-09-23.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A 'MessagingCollectionViewFlowLayoutInvalidationContext' instance specifies properties for
 *  determining whether to recompute the size of items or their position in the layout.
 *  The flow layout object creates instances of this class when it needs to invalidate its contents
 *  in response to changes.
 */
@interface MessagingCollectionViewFlowLayoutInvalidationContext : UICollectionViewFlowLayoutInvalidationContext

/**
 *  A boolean indication whether to empty the layout information cache for items and views in the layout
 *  The default is 'NO'.
 */
@property (assign, nonatomic) BOOL emptyCache;

/**
 *  Creates and returns a new 'MessagingCollectionViewFlowLayoutInvalidationContext' object.
 *
 *  @discussion When you need to invalidate the 'MessagignCollectionView' object for your
 *  'MessagingViewController' subclass, you should use this method to instantiate a new invalidation
 *  context and pass this object to 'invalidateLayoutWithContext:'.
 *
 *  @return An initialized invalidation context object if successful, otherwise 'nil'.
 */
+ (instancetype)context;

@end
