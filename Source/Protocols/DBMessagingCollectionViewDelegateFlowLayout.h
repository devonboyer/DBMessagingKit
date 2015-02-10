//
//  DBMessagingCollectionViewDelegateFlowLayout.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-10-12.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

@class DBMessagingCollectionViewBaseFlowLayout;

/**
 *  The 'DBMessagingCollectionViewDelegateFlowLayout' protocol defines methods that allow you to
 *  manage additional layout information for the collection view.
 */
@protocol DBMessagingCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@optional

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(DBMessagingCollectionViewBaseFlowLayout *)collectionViewLayout referenceSizeForMediaViewAtIndexPath:(NSIndexPath *)indexPath;

@end
