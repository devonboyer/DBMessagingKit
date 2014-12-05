//
//  MessagingViewController.h
//  MessagingKit
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
@class MessageInputView;
@class InteractiveKeyboardController;

@interface MessagingViewController : UIViewController <MessagingCollectionViewDataSource, MessagingCollectionViewDelegateFlowLayout>

@property (strong, nonatomic, readonly) MessagingCollectionView *collectionView;
@property (strong, nonatomic, readonly) InteractiveKeyboardController *keyboardController;
@property (strong, nonatomic, readonly) UIView<MessagingInputUtility> *messageInputView;

/**
 *  Specifies the class from which to instantiate the chat input view. The class will be instantiated via alloc/initWithFrame:
 *  The initial size for the chat input view is the {collectionView.frame.size.width, 50.0}. To specify a different initial size for the
 *  chatInputView use registerClassForChatInputView:withInitialSize: instead. 
 *
 *  This is the recommended initial size for the 'IGChatiMessageInputView'.
 *
 *  @param viewClass   The class from which to instantiate the chatInputView.
 *
 *  @warning The registered chatInputView must conform to 'IGChatInputUtility' and be a subclass of 'UIView'.
 *  DO NOT set your 'IGChatManagerViewController' subclass as the delegate of the textView unless you would like to handle
 *  resizing behaviour yourself.
 *
 *  @see 'IGChatInputUtility'
 */
- (void)registerClassForMessageInputView:(Class)viewClass;

/**
 *  Specifies the class from which to instantiate the chat input view. The class will be instantiated via alloc/initWithFrame: with the
 *  given initial size.
 *
 *  It is recommended that you register a custom chat input view if you would like to specify a custom initial size.
 *
 *  @param viewClass      The class from which to instantiate the chatInputView.
 *  @param initialSize    The initial size for the chat input view.
 *
 *  @warning The registered chatInputView must conform to 'IGChatInputUtility' and be a subclass of 'UIView'.
 *  DO NOT set your 'IGChatManagerViewController' subclass as the delegate of the textView unless you would like to handle
 *  resizing behaviour yourself.
 *
 *  @see 'IGChatInputUtility'
 */
- (void)registerClassForMessageInputView:(Class)viewClass withInitialHeight:(CGFloat)initialHeight;


/**
 *  Specifies whether or not to accept any auto-correct suggestions before sending a message.
 *
 *  @discussion The default value is 'YES'.
 */
@property (nonatomic) BOOL acceptsAutoCorrectBeforeSending;

/**
 *  Specifies whether or not the view controller should automatically scroll to the most recent message
 *  when the view appears and when sending, receiving, and composing a new message.
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
 *  This method is called when the user taps the send button on the inputToolbar
 *  after composing a message with the specified text.
 *
 *  @param text   The message text.
 *
 *  @discussion   The message sender is always the senderId specified by the data source. The message data will be the current
 *  date returned by [NSDate date].
 *
 * @see 'senderId'
 */
- (void)sendMessageWithText:(NSString *)text;

/**
 *  This method is called when the user selects a photo from the photo gallery or takes a picture with the camera.
 *  after composing a message with the specified data.
 *
 *  @param text   The message photo.
 *
 *  @discussion   The message sender is always the senderId specified by the data source. The message data will be the current
 *  date returned by [NSDate date].
 *
 *  @see 'senderId'
 */
- (void)sendMessageWithPhoto:(UIImage *)photo;

/**
 *  Completes the "sending" of a new message by animating and resetting the 'inputToolbar',
 *  animating the addition of a new collection view cell in the collection view,
 *  reloading the collection view, and scrolling to the newly sent message
 *  as specified by 'automaticallyScrollsToMostRecentMessage'.
 *
 *  @discussion You should call this method at the end of 'sendMessageWithText:' and 'sendMessageWithPhoto:'
 *  after adding the new message to your data source and performing any related tasks.
 *
 *  @see 'automaticallyScrollsToMostRecentMessage`.
 *  @see 'sendMessageWithText:' and 'sendMessageWithPhoto:'.
 */
- (void)finishSendingMessage;

/**
 *  Completes the "receiving" of a new message by animating the typing indicator,
 *  animating the addition of a new collection view cell in the collection view,
 *  reloading the collection view, and scrolling to the newly sent message
 *  as specified by 'automaticallyScrollsToMostRecentMessage'.
 *
 *  @discussion You should call this method after adding a new "received" message
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

- (void)updateCollectionViewInsets;
- (void)updateKeyboardTriggerPoint;
- (void)setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom;

@end
