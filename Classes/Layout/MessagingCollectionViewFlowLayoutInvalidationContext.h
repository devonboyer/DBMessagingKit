//
//  MessagingCollectionViewFlowLayoutInvalidationContext.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-09-23.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagingCollectionViewFlowLayoutInvalidationContext : UICollectionViewFlowLayoutInvalidationContext

/**
 * A boolean indication whether to empty the layout information cache for items and views in the layout
 * The default is 'NO'.
 */
@property (assign, nonatomic) BOOL emptyCache;

+ (instancetype)context;

@end
