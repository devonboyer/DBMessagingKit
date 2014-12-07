//
//  MessagingCollectionViewFlowLayout.h
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-09-19.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessagingCollectionView;

extern NSString * const MessagingCollectionElementKindTimestamp;

/**
 *  The 'MessagingCollectionViewFlowLayout' organizes message items in a vertical list.
 *  Each 'MessagingParentCell' in the layout can display messages of arbitrary sizes and avatar images,
 *  as well as metadata such as a timestamp and sender. You can easily customize the layout via its properties.
 *
 *  @see MessagingParentCell
 */
@interface MessagingCollectionViewFlowLayout : UICollectionViewFlowLayout

/**
 *  The collection view object currently using this layout object.
 */
@property (strong, nonatomic, readonly) MessagingCollectionView *collectionView;

/**
 *  Specifies whether or not the layout should enable spring behavior dynamics.
 *
 *  @discussion The default value is 'NO', which disables "springy" or "bouncy" items in the layout.
 *  Set to 'YES' if you want items to have spring behavior dynamics similar to iMessage.
 *
 *  @warning Though this feature is mostly stable, it is still considered an experimental feature.
 */
@property (assign, nonatomic) BOOL dynamicsEnabled;

/**
 *  Specifies the degree of resistence for the 'springiness' of items in the layout.
 *  This property has no effect if 'dynamicsEnabled' is set to 'NO'.
 *
 *  @discussion The default value is '1000'. Increasing this value increases the resistance, that is, items become less
 * 'bouncy'.
 */
@property (assign, nonatomic) CGFloat springResistanceFactor;

/**
 *  Returns the width of items in the layout.
 */
@property (assign, nonatomic, readonly) CGFloat itemWidth;

/**
 *  Specifies the indexPath that recieved a tap event in order to display or hide a 'MessagingTimestampSupplementaryView'.
 */
@property (strong, nonatomic) NSIndexPath *tappedIndexPath;

/**
 *  Specifies the padding that should be applied to the 'cellTopLabel'.
 *
 *  @discussion The 'cellToplabel' height is calculated using the boundingBox of the attributed string passed
 *  by the appropriate dataSource method.
 */
@property (assign, nonatomic) CGFloat cellTopLabelPadding;

/**
 *  Specifies the padding that should be applied to the 'messageTopLabel'.
 *
 *  @discussion The 'messageTopLabel' height is calculated using the boundingBox of the attributed string passed
 *  by the appropriate dataSource method.
 */
@property (assign, nonatomic) CGFloat messageTopLabelPadding;

/**
 *  Specifies the padding that should be applied to the 'cellBottomLabel'.
 *
 *  @discussion The 'cellBottomlabel' height is calculated using the boundingBox of the attributed string passed
 *  by the appropriate dataSource method.
 */
@property (assign, nonatomic) CGFloat cellBottomLabelPadding;

/**
 *  Specifies the padding that should be applied to the 'timestampSupplementaryView'.
 *
 *  @discussion The 'timestampSupplementaryView' height is calculated using the boundingBox of the attributed string
 *  passed by the appropriate dataSource method.
 */
@property (assign, nonatomic) CGFloat timestampSupplementaryViewPadding;

/**
 *  The following attibutes can be set to customize the appearance of the layout.
 *
 *  @discussion The following attributes correspond to the attributes in a 'MessagingCollectionViewLayoutAttributes'
 *  instance.
 *
 *  @see 'MessagingCollectionViewLayoutAttributes'
 */
@property (strong, nonatomic) UIFont *messageBubbleFont;
@property (assign, nonatomic) UIEdgeInsets messageBubbleTextViewTextContainerInsets;
@property (assign, nonatomic) CGSize incomingAvatarViewSize;
@property (assign, nonatomic) CGSize outgoingAvatarViewSize;
@property (assign, nonatomic) CGSize incomingPhotoImageSize;
@property (assign, nonatomic) CGSize outgoingPhotoImageSize;
@property (assign, nonatomic) CGSize incomingLocationMapSize;
@property (assign, nonatomic) CGSize outgoingLocationMapSize;
@property (assign, nonatomic) CGFloat messageBubbleLeftRightMargin;
@property (assign, nonatomic) CGFloat incomingMessageBubbleAvatarSpacing;
@property (assign, nonatomic) CGFloat outgoingMessageBubbleAvatarSpacing;
@property (assign, nonatomic) CGFloat inOutMessageBubbleInteritemSpacing;

/**
 *  Computes and returns the size of the item specified by indexPath.
 *
 *  @param indexPath The index path of the item to be displayed.
 *
 *  @return The size of the item displayed at indexPath.
 */
- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
