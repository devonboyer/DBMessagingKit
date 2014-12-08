//
//  MessagingCollectionViewLayoutAttributes.h
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-09-22.
//  Copyright (c) 2014 Devon Boyer . All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A 'MessagingCollectionViewLayoutAttributes' object manages the layout-related attributes
 *  for a given 'MessagingParentCell' in a 'MessagingCollectionView'.
 */
@interface MessagingCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes <NSCopying>

/**
 *  The font used to display the message text.
 *
 *  @warning The messageBubbleFont cannot be 'nil'.
 */
@property (strong, nonatomic) UIFont *messageBubbleFont;

/**
 *  The height of the message bubble's top label.
 */
@property (assign, nonatomic) CGFloat messageBubbleTopLabelHeight;

/**
 *  The height of the cell top label.
 */
@property (assign, nonatomic) CGFloat cellTopLabelHeight;

/**
 *  The height of the cell bottom label.
 */
@property (assign, nonatomic) CGFloat cellBottomLabelHeight;

/**
 *  The size of the avatar for incoming messages.
 *
 *  @warning The width of the incoming avatar must be equal to the height.
 */
@property (assign, nonatomic) CGSize incomingAvatarViewSize;

/**
 *  The size of the avatar for outgoing messages.
 *
 *  @warning The width of the outgoing avatar must be equal to the height.
 */
@property (assign, nonatomic) CGSize outgoingAvatarViewSize;

/**
 *  The maximum amount of space between the messageBubble and the edge of the screen.
 *  The default value is 60.0.
 */
@property (assign, nonatomic) CGFloat messageBubbleLeftRightMargin;

/**
 *  The amount of spacing inbetween the avatar and message bubble for incoming messages.
 *
 *  @discussion The spacing will be set to 0.0 if incomingAvatarSize.width is set to 0.0.
 *
 */
@property (assign, nonatomic) CGFloat incomingMessageBubbleAvatarSpacing;

/**
 *  The amount of spacing inbetween the avatar and message bubble for outgoing messages.
 *
 *  @discussion The spacing will be set to 0.0 if outgoingAvatarSize.width is set to 0.0.
 */
@property (assign, nonatomic) CGFloat outgoingMessageBubbleAvatarSpacing;

/**
 *  The inset of the text container's layout area within the text view's content area in a 'ChatCollectionViewCell'.
 *  The specified inset values should be greater than or equal to 0.0.
 */
@property (assign, nonatomic) UIEdgeInsets messageBubbleTextViewTextContainerInsets;

/**
 *  The size of the photo for incoming photo messages.
 *
 *  @discussion The width value is used to determine the height that will maintain the same aspect ratio.
 *  The height value will be used as the maximum height.
 */
@property (assign, nonatomic) CGSize incomingImageSize;

/**
 *  The size of the photo for outgoing photo messages.
 *
 *  @discussion The width value is used to determine the height that will maintain the same aspect ratio.
 *  The height value will be used as the maximum height.
 */
@property (assign, nonatomic) CGSize outgoingImageSize;

/**
 *  The size of the map view for incoming location messages.
 */
@property (assign, nonatomic) CGSize incomingLocationMapSize;

/**
 *  The size of the map view for outgoing location messages.
 */
@property (assign, nonatomic) CGSize outgoingLocationMapSize;

/**
 *  The interitem spacing between an incoming and outgoing message.
 *
 *  @discussion The minimumLineSpacing property of a 'UICollectionViewFlowLayout' handles spacing between
 *  consecutive messages by the same sentByUserID, while the inOutMessageBubbleInteritemSpacing will handle the spacing
 *  between an incoming and outgoing message which is typically larger. The default is '5.0'.
 */
@property (assign, nonatomic) CGFloat inOutMessageBubbleInteritemSpacing;

@end
