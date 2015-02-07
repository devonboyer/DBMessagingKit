//
//  DBMessagingViewController.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//
//  Created by Devon Boyer on 2014-10-12.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

#import "DBMessagingKitConstants.h"
#import "DBMessagingCollectionViewDataSource.h"
#import "DBMessagingCollectionViewDelegateFlowLayout.h"

@class DBMessagingCollectionView;
@class DBInteractiveKeyboardController;
@class DBMessagingInputToolbar;

/**
 *  The 'DBMessagingViewController' class is an abstract class that represents a view controller whose content consists of
 *  a 'DBMessagingCollectionView' and 'DBMessagingInputToolbar' and is specialized to display a messaging interface.
 *
 *  @warning This class is intended to be subclassed. You should not use it directly.
 */
@interface DBMessagingViewController : UIViewController <DBMessagingCollectionViewDataSource, DBMessagingCollectionViewDelegateFlowLayout>

/**
 *  Returns the collection view object managed by this view controller.
 *  This view controller is the collection view's data source and delegate.
 */
@property (strong, nonatomic, readonly) DBMessagingCollectionView *collectionView;

/**
 *  The keyboard controller object for the 'DBMessagingViewController
 */
@property (strong, nonatomic, readonly) DBInteractiveKeyboardController *keyboardController;

/**
 *  Returns the messaging input view for the 'DBMessagingViewController'
 */
@property (strong, nonatomic, readonly) DBMessagingInputToolbar *messageInputToolbar;

/**
 *  Specifies whether or not to accept any auto-correct suggestions before sending a message.
 *
 *  @discussion The default value is 'YES'.
 */
@property (nonatomic) BOOL acceptsAutoCorrectBeforeSending;

/**
 *  Specifies whether or not the view controller should automatically scroll to the most recent message
 *  when composing a new message and when sending or receiving a new message.
 *
 *  @discussion The default value is 'YES', which allows the view controller to scroll automatically to the most recent message.
 *  Set to 'NO' if you want to manage scrolling yourself.
 */
@property (assign, nonatomic) BOOL automaticallyScrollsToMostRecentMessage;

/**
 *  Specifies whether or not the view controller should show the "load earlier messages" header view.
 *
 *  @discussion Setting this property to 'YES' will show the header view immediately.
 *  Settings this property to 'NO' will hide the header view immediately. You will need to scroll to
 *  the top of the collection view in order to see the header.
 */
@property (nonatomic) BOOL showLoadMoreMessages;

/**
 *  Specifies whether or not the view controller should show the typing indicator for an incoming message.
 *
 *  @discussion Setting this property to 'YES' will animate showing the typing indicator immediately.
 *  Setting this property to 'NO' will animate hiding the typing indicator immediately. You will need to scroll
 *  to the bottom of the collection view in order to see the typing indicator. You may use 'scrollToBottomAnimated:' for this.
 */
@property (nonatomic) BOOL showTypingIndicator;

/**
 *  This method is automatically called when the user taps the send button on the registered UIView<MessageInputUtility>
 *  after composing a message with the appropriate data and MIMEType.
 *
 *  @param data     The data to be embedded in the message.
 *  @param MIMEType A MIME Type identifying the type of data contained in the given data object.
 *
 *  @see MessageInputUtility
 */
- (void)sendMessageWithData:(NSData *)data MIMEType:(MIMEType)MIMEType;

- (void)sendCurrentlyComposedText;

/**
 *  A convenience method for returning the index path fo the latest message that was sent or recieved.
 *
 *  @return Returns the indexPath for the latest message.
 */
- (NSIndexPath *)indexPathForLatestMessage;

/**
 *  Completes the sending of a new message by clearing the currently composed text,
 *  reloading the collection view, and scrolling to the newly sent message
 *  as specified by 'automaticallyScrollsToMostRecentMessage'.
 *
 *  @discussion You should call this method after adding a new sent message
 *  to your data source and performing any related tasks.
 *
 *  @see 'automaticallyScrollsToMostRecentMessage'.
 */
- (void)finishSendingMessage;

/**
 *  Completes the receiving of a new message by animating the typing indicator,
 *  animating the addition of a new collection view cell in the collection view,
 *  reloading the collection view, and scrolling to the newly received message
 *  as specified by 'automaticallyScrollsToMostRecentMessage'.
 *
 *  @discussion You should call this method after adding a new received message
 *  to your data source and performing any related tasks.
 *
 *  @see 'automaticallyScrollsToMostRecentMessage'.
 */
- (void)finishReceivingMessage;

/**
 *  Scrolls the collection view such that the bottom most cell is completely visible, above the 'inputToolbar'.
 *
 *  @param animated Pass 'YES' if you want to animate scrolling, 'NO' if it should be immediate.
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

@end
