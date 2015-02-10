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

/**
 *  The 'DBMessagingCollectionViewDelegateFlowLayout' protocol defines methods that allow you to
 *  manage additional layout information for the collection view.
 */
@protocol DBMessagingCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@optional

// Asks the delegate for the estimated size for the media view at the specified indexPath
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout estimatedSizeForMediaViewAtIndexPath:(NSIndexPath *)indexPath;

@end
