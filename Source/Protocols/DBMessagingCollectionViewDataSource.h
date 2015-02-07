//
//  DBMessagingCollectionViewDataSource.h
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

#import "DBMessagingKitConstants.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class DBMessagingCollectionView;

/**
 *  An object that conforms to the 'DBMessagingCollectionViewDataSource' protocol is responsible for providing the data
 *  and views required by a 'DBMessagingCollectionView'. The data source object represents your app’s messaging data model
 *  and vends information to the collection view as needed.
 */
@protocol DBMessagingCollectionViewDataSource <UICollectionViewDataSource>

@required

/**
 *  Asks the data source for the message sender, that is, the user who is sending messages.
 *
 *  @return An initialized string describing the sender. You must not return `nil` from this method.
 */
- (NSString *)senderUserID;

/**
 *  Asks the data source for the identifier of the user who sent the message at the speficied
 *  indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return The identifier of the user who sent the message.
 */
- (NSString *)collectionView:(UICollectionView *)collectionView sentByUserIDForMessageAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source for the MIME Type identifying the type of data contained in the given data object at the speficied 
 *  indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return A MIME Type identifying the type of data contained in the given data object.
 */
- (MIMEType)collectionView:(UICollectionView *)collectionView MIMETypeForMessageAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source for the data to be embedded in the message at the  specified indexPath in the collectionView.
 *
 *  @discussion Returning 'nil' from this method will trigger the data source to call
 *  collectionView:wantsPhotoForImageView:atIndexPath or collectionView:wantsMessageLocationData:atIndexPath
 *  where the data can then be downloaded from the server if required.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return The data to be embedded in the message.
 */
- (NSData *)collectionView:(UICollectionView *)collectionView dataForMessageAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source for the bubble image that corresponds to the specified
 *  message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @discussion It is recommended that you utilize 'MessageBubbleController' to return valid imageViews, however you may
 *  provide your own.
 *
 *  @return A configured image. You may return 'nil' from this method if you do not want the specified item to display a 
 *  message bubble image.
 *
 *  @see 'MessageBubbleController'
 *  @see 'MessagingCollectionViewFlowLayout'.
 */
- (UIImageView *)collectionView:(UICollectionView *)collectionView messageBubbleForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 *  Asks the data source to set the photo to display in the imageView for the the specified
 *  message data item at indexPath in the collectionView.
 *
 *  @param collectionView   The object representing the collection view requesting this information.
 *  @param indexPath        The index path that specifies the location of the item.
 *
 *  @return The location that represents the message.
 */
- (CLLocation *)collectionView:(UICollectionView *)collectionView locationForMessageAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source for the attributed text to display in the 'messageBubbleTopLabel' for the specified
 *  message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return A configured attributed string or 'nil' if you do not want text displayed for the item at indexPath.
 *  Return an attributed string with 'nil' attributes to use the default attributes.
 *
 *  @discussion The 'messageTopLabel' is typically used to display the sender's name.
 *
 *  @see 'MessagingParentCell'.
 */
- (NSAttributedString *)collectionView:(UICollectionView *)collectionView messageTopLabelAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source for the attributed text to display in the 'cellTopLabel' for the specified
 *  message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return A configured attributed string or 'nil' if you do not want text displayed for the item at indexPath.
 *  Return an attributed string with 'nil' attributes to use the default attributes.
 *
 *  @discussion The 'cellTopLabel' is typically used to display formatted timestamps.
 *
 *  @see 'MessagingParentCell'.
 */
- (NSAttributedString *)collectionView:(UICollectionView *)collectionView cellTopLabelAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source for the attributed text to display in the 'cellBottomLabel' for the the specified
 *  message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @return A configured attributed string or 'nil' if you do not want text displayed for the item at indexPath.
 *  Return an attributed string with 'nil' attributes to use the default attributes.
 *
 *  @discussion The 'cellBottomLabel' is typically used to display delivery status.
 *
 *  @see 'MessagingParentCell'.
 */
- (NSAttributedString *)collectionView:(UICollectionView *)collectionView cellBottomLabelAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source for the attributed text to display for the timestamp of the specified
 *  message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @discussion The timestamp is displayed when a message bubble receives a tap event.
 */
- (NSAttributedString *)collectionView:(UICollectionView *)collectionView timestampAttributedTextForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source to set the avatar to display in the imageView for the the specified
 *  message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param imageView      The imageView that the will display the avatar.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @discussion The avatar image can be set using this method after downloading the image from the server. Setting the 
 *  imageView's image to 'nil' will hide the avatar.
 */
- (void)collectionView:(DBMessagingCollectionView *)collectionView wantsAvatarForImageView:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath;

/**
 *  Asks the data source to set the photo to display in the imageView for the the specified
 *  message data item at indexPath in the collectionView.
 *
 *  @param collectionView The object representing the collection view requesting this information.
 *  @param imageView      The imageView that the will display the photo.
 *  @param indexPath      The index path that specifies the location of the item.
 *
 *  @discussion This method will be called if the message data is 'nil' and the MIMEType is MIMETypeImage or MIMETypeVideo in 
 *  order to then download the image or video from the server if required.
 */
- (void)collectionView:(DBMessagingCollectionView *)collectionView wantsImageForImageView:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath;

@end
