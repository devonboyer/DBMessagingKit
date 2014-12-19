//
//  MessagingViewController.h
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-10-12.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MessagingKitConstants.h"
#import "MessagingInputUtility.h"
#import "MessagingCollectionViewDataSource.h"
#import "MessagingCollectionViewDelegateFlowLayout.h"

@class MessagingCollectionView;
@class InteractiveKeyboardController;

/**
 *  The 'MessagingViewController' class is an abstract class that represents a view controller whose content consists of
 *  a 'MessagingCollectionView' and 'UIView<MessagingInputUtility>' and is specialized to display a messaging interface.
 *
 *  @warning This class is intended to be subclassed. You should not use it directly.
 */
@interface MessagingViewController : UIViewController <MessagingCollectionViewDataSource, MessagingCollectionViewDelegateFlowLayout>

/**
 *  Returns the collection view object managed by this view controller.
 *  This view controller is the collection view's data source and delegate.
 */
@property (strong, nonatomic, readonly) MessagingCollectionView *collectionView;

/**
 *  The keyboard controller object for the 'MessagingViewController
 */
@property (strong, nonatomic, readonly) InteractiveKeyboardController *keyboardController;

/**
 *  Returns the messaging input view for the 'MessagingViewController'
 */
@property (strong, nonatomic, readonly) UIView<MessagingInputUtility> *messageInputView;

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
 *  The indexPaths of messages that are currently 'sending'.
 *
 *  @discussion To finish sending a message call 'finishSendingMessageAtIndexPath:' or 'finishSendingAllMessages'.
 */
@property (strong, nonatomic) NSMutableArray *currentlySendingMessageIndexPaths;

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

/**
 *  Begins the sending of a new message by animating and resetting the registered UIView<MessageInputUtility>,
 *  animating the addition of a new collection view cell in the collection view, reloading the collection view, 
 *  and scrolling to the newly sent message as specified by 'automaticallyScrollsToMostRecentMessage'.
 *
 *  @discussion You should call this method at the end of 'sendMessageWithData:MIMEType' after adding the new 
 *  message to your data source and performing any related tasks. You must call then either
 *  'finishSendingMessageAtIndexPath:' or 'updateMessageSendingProgress:forItemAtIndexPath:' when appropriate.
 */
- (void)beginSendingMessage;

/**
 *  Updates the sending progress of a message by increasing the alpha of the message to simulate sending
 *  progress.
 *
 *  @discussion The progress of a message will always be between 0.2 and 1.0 to maintain the user experience.
 *
 *  @param indexPath The indexPath of the message to update.
 *  @param progress The sending progress of the message.
 */
- (void)updateMessageSendingProgress:(CGFloat)progress forItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Finish the sending progress of a message by increasing the alpha of the message to 1.0.
 *
 *  @param indexPath The indexPath of the message that has finished sending..
 */
- (void)finishSendingMessageAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Finish the sending progress of a message by increasing the alpha to 1.0 of all messages in
 * 'currentlySendingMessagesIndexPaths'.
 */
- (void)finishSendingAllMessages;

/**
 *  A convenience method for returning the index path fo the latest message that was sent or recieved.
 *
 *  @return Returns the indexPath for the latest message.
 */
- (NSIndexPath *)indexPathForLatestMessage;

/**
 *  Completes the receiving of a new message by animating the typing indicator,
 *  animating the addition of a new collection view cell in the collection view,
 *  reloading the collection view, and scrolling to the newly sent message
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

/**
 *  Specifies the class from which to instantiate the messaging input view. The class will be instantiated via alloc/
 *  initWithFrame:. The initial size for the messaging input view is '50.0'. To specify a different initial size for the
 *  messaging input view use registerClassForMessageInputView:withInitialHeight: instead.
 *
 *  @discussion This is the recommended registration method for the 'MessagingInputView'.
 *
 *  @param viewClass The class from which to instantiate the chatInputView.
 *
 *  @warning The registered chatInputView must conform to 'MessagingInputUtility' and be a subclass of 'UIView'.
 *
 *  @see 'MessagingInputUtility'
 */
- (void)registerClassForMessageInputView:(Class)viewClass;

/**
 *  Specifies the class from which to instantiate the chat input view. The class will be instantiated via alloc/initWithFrame:
 *  with the given initial size.
 *
 *  It is recommended that you register a custom chat input view if you would like to specify a custom initial size.
 *
 *  @param viewClass      The class from which to instantiate the chatInputView.
 *  @param initialSize    The initial size for the chat input view.
 *
 *  @warning The registered chatInputView must conform to 'MessagingInputUtility' and be a subclass of 'UIView'.
 *
 *  @see 'MessagingInputUtility'
 */
- (void)registerClassForMessageInputView:(Class)viewClass withInitialHeight:(CGFloat)initialHeight;

@end
