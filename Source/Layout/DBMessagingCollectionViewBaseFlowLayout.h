//
//  DBMessagingCollectionViewBaseFlowLayout.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-19.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

@class DBMessagingCollectionView;

extern NSString * const DBMessagingCollectionElementKindTimestamp;

/*!
 *  The 'DBMessagingCollectionViewBaseFlowLayout' organizes message items in a vertical list.
 *  Each 'DBMessagingParentCell' in the layout can display messages of arbitrary sizes and avatar images,
 *  as well as metadata such as a timestamp and sender. You can easily customize the layout via its properties.
 *
 *  @see DBMessagingParentCell
 */
@interface DBMessagingCollectionViewBaseFlowLayout : UICollectionViewFlowLayout

- (void)commonInit;

/**
 *  The collection view object currently using this layout object.
 */
@property (strong, nonatomic, readonly) DBMessagingCollectionView *collectionView;

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
 *  The interitem spacing between an incoming and outgoing message.
 *
 *  @discussion The minimumLineSpacing property of a 'UICollectionViewFlowLayout' handles spacing between
 *  consecutive messages by the same sentByUserID, while the inOutMessageBubbleInteritemSpacing will handle the spacing
 *  between an incoming and outgoing message which is typically larger. The default is '5.0'.
 */
@property (assign, nonatomic) CGFloat inOutMessageBubbleInteritemSpacing;

@property (assign, nonatomic) CGSize mediaViewReferenceSize;

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
@property (assign, nonatomic) CGFloat messageBubbleLeftRightMargin;
@property (assign, nonatomic) CGFloat incomingMessageBubbleAvatarSpacing;
@property (assign, nonatomic) CGFloat outgoingMessageBubbleAvatarSpacing;

/**
 *  Computes and returns the size of the item specified by indexPath.
 *
 *  @param indexPath The index path of the item to be displayed.
 *
 *  @return The size of the item displayed at indexPath.
 */
- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Returns true if the message at a given index path is an outgoing message or false
 *  if the message is an incoming message.
 *
 *  @param indexPath The index path of the item.
 *
 *  @return Returns true if the message is an outgoing message or false otherwise.
 */
- (BOOL)isOutgoingMessageAtIndexPath:(NSIndexPath *)indexPath;

- (CGSize)avatarSizeForIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)messageBubbleAvatarSpacingForIndexPath:(NSIndexPath *)indexPath;

@end
