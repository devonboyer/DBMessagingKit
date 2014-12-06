//
//  MessagingViewController.m
//  MessagingKit
//
//  Created by Devon Boyer on 2014-10-12.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingViewController.h"

// Controllers
#import "InteractiveKeyboardController.h"
#import "MessageBubbleController.h"
#import "MessagingInputTextView.h"
#import "MessagingCollectionView.h"
#import "MessagingCollectionViewFlowLayout.h"
#import "MessagingCollectionViewFlowLayoutInvalidationContext.h"
#import "MessagingTextCell.h"
#import "MessagingPhotoCell.h"
#import "MessagingTimestampSupplementaryView.h"
#import "MessagingLoadEarlierMessagesHeaderView.h"
#import "MessagingTypingIndicatorFooterView.h"

@interface MessagingViewController () <MessagingInputTextViewDelegate, InteractiveKeyboardControllerDelegate>

@property (strong, nonatomic) MessagingCollectionView *collectionView;
@property (strong, nonatomic) UIView<MessagingInputUtility> *messageInputView;
@property (strong, nonatomic) InteractiveKeyboardController *keyboardController;

- (void)_messageInputView:(UIView<MessagingInputUtility> *)chatInputView sendButtonTapped:(UIButton *)sendButton;

- (void)_finishSendingOrReceivingMessage;
- (void)_toggleSendButtonEnabled;
- (void)_clearCurrentlyComposedText;
- (NSString *)_currentlyComposedText;

@end

@implementation MessagingViewController

- (void)loadView
{
    [super loadView];
    
    MessagingCollectionViewFlowLayout *collectionViewLayout = [[MessagingCollectionViewFlowLayout alloc] init];
    _collectionView = [[MessagingCollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:collectionViewLayout];
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [self.view addSubview:_collectionView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyScrollsToMostRecentMessage = YES;
    self.acceptsAutoCorrectBeforeSending = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarDidChangeFrame:)
                                                 name:UIApplicationDidChangeStatusBarFrameNotification
                                               object:nil];
    
    [self.view layoutIfNeeded];
    [_collectionView reloadData];
    [_collectionView.collectionViewLayout invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
    
    [self scrollToBottomAnimated:NO];
    [self updateKeyboardTriggerPoint];
    [_keyboardController beginListeningForKeyboard];
    
    [self updateCollectionViewInsets];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_keyboardController endListeningForKeyboard];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidChangeStatusBarFrameNotification
                                                  object:nil];
}

#pragma mark - Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_collectionView.collectionViewLayout invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

#pragma mark - Setters

- (void)setShowLoadMoreMessages:(BOOL)showLoadMoreMessages
{
    if (_showLoadMoreMessages == showLoadMoreMessages) {
        return;
    }
    
    _showLoadMoreMessages = showLoadMoreMessages;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)setShowTypingIndicator:(BOOL)showTypingIndicator
{
    if (_showTypingIndicator == showTypingIndicator) {
        return;
    }
    
    if (_showTypingIndicator == showTypingIndicator) {
        return;
    }
    
    _showTypingIndicator = showTypingIndicator;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Actions

- (void)sendMessageWithText:(NSString *)text { }

- (void)sendMessageWithPhoto:(UIImage *)photo { }

- (void)finishSendingMessage
{
    [self _clearCurrentlyComposedText];
    [self _toggleSendButtonEnabled];
    
    [self _finishSendingOrReceivingMessage];
}

- (void)finishReceivingMessage
{
    self.showTypingIndicator = NO;
    
    [self _finishSendingOrReceivingMessage];
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    if ([_collectionView numberOfSections] == 0) {
        return;
    }
    
    NSInteger items = [_collectionView numberOfItemsInSection:0];
    
    if (items > 0) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:items - 1 inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionTop
                                            animated:animated];
    }
}

#pragma mark - Public

- (void)registerClassForMessageInputView:(Class)viewClass
{
    NSAssert([viewClass isSubclassOfClass:[UIView class]], @"%@ must be a subclass of '%@'", viewClass, NSStringFromClass([UIView class]));
    NSAssert([viewClass conformsToProtocol:@protocol(MessagingInputUtility)], @"%@ must conform to '%@'", viewClass, NSStringFromProtocol(@protocol(MessagingInputUtility)));
    
    _messageInputView = [[viewClass alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 50.0, CGRectGetWidth(self.view.frame), 50.0)];
    [_messageInputView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [[_messageInputView textView] setDelegate:self];
    [[_messageInputView sendButton] addTarget:self action:@selector(_messageInputView:sendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_messageInputView];

    [self updateCollectionViewInsets];
    [self _configureKeyboardController];
    [self _toggleSendButtonEnabled];
}

- (void)registerClassForMessageInputView:(Class)viewClass withInitialHeight:(CGFloat)initialHeight
{
    NSAssert([viewClass isSubclassOfClass:[UIView class]], @"%@ must be a subclass of '%@'", viewClass, NSStringFromClass([UIView class]));
    NSAssert([viewClass conformsToProtocol:@protocol(MessagingInputUtility)], @"%@ must conform to '%@'", viewClass, NSStringFromProtocol(@protocol(MessagingInputUtility)));
    
    _messageInputView = [[viewClass alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - initialHeight, CGRectGetWidth(self.view.bounds), initialHeight)];
    [_messageInputView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [[_messageInputView textView] setDelegate:self];
    [[_messageInputView sendButton] addTarget:self action:@selector(_messageInputView:sendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_messageInputView];
    
    [self updateCollectionViewInsets];
    [self _configureKeyboardController];
    [self _toggleSendButtonEnabled];
}

#pragma mark - Private

- (void)_configureKeyboardController
{
    _keyboardController = [[InteractiveKeyboardController alloc] initWithTextView:_messageInputView.textView
                                                                        contextView:self.view
                                                                panGestureRecognizer:_collectionView.panGestureRecognizer
                                                                            delegate:self];
}

- (void)_finishSendingOrReceivingMessage
{
    NSUInteger previousNumberOfMessages = [_collectionView numberOfItemsInSection:0];
    NSIndexPath *lastMessageIndexPath = [NSIndexPath indexPathForRow:previousNumberOfMessages inSection:0];
    
    // Insert the new message
    [_collectionView performBatchUpdates:^{
         [_collectionView insertItemsAtIndexPaths:@[lastMessageIndexPath]];
    } completion:nil];
    
    // Reload the previous few index paths not including th last message in reload message bubbles and avatars
    NSMutableArray *indexPathsToReload = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < previousNumberOfMessages; ++i) {
        if (i < 0) continue;
        [indexPathsToReload addObject: [NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [_collectionView reloadItemsAtIndexPaths:indexPathsToReload];
        
    if (_automaticallyScrollsToMostRecentMessage) {
        [self updateCollectionViewInsets];
        [self scrollToBottomAnimated:YES];
    }
}

- (void)_messageInputView:(UIView<MessagingInputUtility> *)messageInputView sendButtonTapped:(UIButton *)sendButton
{
    if ([self _currentlyComposedText].length > 0) {
        [self sendMessageWithText:[self _currentlyComposedText]];
    }
}

- (void)_toggleSendButtonEnabled
{
    UITextView *textView = [_messageInputView textView];
    UIButton *sendButton = [_messageInputView sendButton];
    sendButton.enabled = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
}

- (void)_clearCurrentlyComposedText
{
    [_messageInputView textView].text = @"";
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:nil];
}

- (NSString *)_currentlyComposedText
{
    NSString *text = [_messageInputView textView].text;
    
    if (_acceptsAutoCorrectBeforeSending) {
        // Accept any auto-correct suggestions before sending.
        text = [text stringByAppendingString:@" "];
    }

    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - MessagingCollectionViewDataSource

- (NSString *)senderUserID
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (NSData *)collectionView:(UICollectionView *)collectionView dataForMessageAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (MIMEType)collectionView:(UICollectionView *)collectionView MIMETypeForMessageAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return 0;
}

- (NSString *)collectionView:(UICollectionView *)collectionView sentByUserIDForMessageAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (UIImageView *)collectionView:(UICollectionView *)collectionView messageBubbleForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (NSAttributedString *)collectionView:(UICollectionView *)collectionView messageTopLabelAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(UICollectionView *)collectionView cellTopLabelAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(UICollectionView *)collectionView cellBottomLabelAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)collectionView:(MessagingCollectionView *)collectionView wantsAvatarForImageView:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath { }

- (void)collectionView:(MessagingCollectionView *)collectionView wantsPhotoForImageView:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath { }

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(MessagingCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isOutgoingMessage = [[self collectionView:collectionView sentByUserIDForMessageAtIndexPath:indexPath] isEqualToString:[self senderUserID]];
    
    NSString *cellIdentifier;
    switch ([self collectionView:collectionView MIMETypeForMessageAtIndexPath:indexPath]) {
        case MIMETypeText: {
            cellIdentifier = kMessagingTextCellIdentifier;
            break;
        }
        case MIMETypeImage: {
            cellIdentifier = kMessagingPhotoCellIdentifier;
            break;
        }
        default:
            break;
    }
    
    MessagingParentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = collectionView;
    cell.collectionView = collectionView;
    cell.type = (isOutgoingMessage) ? IGChatMessageBubbleTypeOutgoing : IGChatMessageBubbleTypeIncoming;
    
    cell.cellTopLabel.attributedText = [collectionView.dataSource collectionView:collectionView cellTopLabelAttributedTextForItemAtIndexPath:indexPath];
    cell.cellBottomLabel.attributedText = [collectionView.dataSource collectionView:collectionView cellBottomLabelAttributedTextForItemAtIndexPath:indexPath];
    cell.messageTopLabel.attributedText = [collectionView.dataSource collectionView:collectionView messageTopLabelAttributedTextForItemAtIndexPath:indexPath];
    cell.messageBubbleImageView.image = [collectionView.dataSource collectionView:collectionView messageBubbleForItemAtIndexPath:indexPath].image;
    cell.messageBubbleImageView.highlightedImage = [collectionView.dataSource collectionView:collectionView messageBubbleForItemAtIndexPath:indexPath].highlightedImage;
    [collectionView.dataSource collectionView:collectionView wantsAvatarForImageView:cell.avatarImageView atIndexPath:indexPath];
    
    switch ([self collectionView:collectionView MIMETypeForMessageAtIndexPath:indexPath]) {
        case MIMETypeText: {
            MessagingTextCell *textCell = (MessagingTextCell *)cell;
            NSString *messageText = [[NSString alloc] initWithData:[self collectionView:collectionView dataForMessageAtIndexPath:indexPath] encoding:NSUTF8StringEncoding];
            textCell.messageText = messageText;
            textCell.messageTextView.dataDetectorTypes = UIDataDetectorTypeAll;
            break;
        }
        case MIMETypeImage:{
            MessagingPhotoCell *photoCell = (MessagingPhotoCell *)cell;
            UIImage *image = [[UIImage alloc] initWithData:[self collectionView:collectionView dataForMessageAtIndexPath:indexPath]];
            if (!image) {
                [collectionView.dataSource collectionView:collectionView wantsPhotoForImageView:photoCell.photoImageView atIndexPath:indexPath];
            }
            else {
                photoCell.photoImageView.image = image;
            }
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(MessagingCollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if (_showTypingIndicator && [kind isEqualToString:UICollectionElementKindSectionFooter]) {
        return [collectionView dequeueTypingIndicatorFooterViewForIndexPath:indexPath];
    }
    else if (_showLoadMoreMessages && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [collectionView dequeueLoadMoreHeaderViewForIndexPath:indexPath];
    }
    else if ([kind isEqualToString:MessagingCollectionElementKindTimestamp]) {
        MessagingTimestampSupplementaryView *supplementaryView = (MessagingTimestampSupplementaryView *)[collectionView dequeueTimestampSupplementaryViewForIndexPath:indexPath];
        
        NSString *sentByUserID = [self collectionView:collectionView sentByUserIDForMessageAtIndexPath:indexPath];
        
        supplementaryView.timestampLabel.attributedText = [collectionView.dataSource collectionView:collectionView timestampAttributedTextForSupplementaryViewAtIndexPath:indexPath];
        supplementaryView.type = ([sentByUserID isEqualToString:[self senderUserID]]) ? IGChatMessageBubbleTypeOutgoing : IGChatMessageBubbleTypeIncoming;
        
        return supplementaryView;
    }
    
    return nil;
}

#pragma mark - MessagingCollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath { }

- (void)collectionView:(UICollectionView *)collectionView didTapPhotoImageView:(UIImageView *)photoImageView atIndexPath:(NSIndexPath *)indexPath { }

- (void)collectionView:(UICollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath { }

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_collectionView.collectionViewLayout sizeForCellAtIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewFlowLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (!_showTypingIndicator) {
        return CGSizeZero;
    }

    return CGSizeMake(_collectionView.collectionViewLayout.itemWidth, 50.0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewFlowLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (!_showLoadMoreMessages) {
        return CGSizeZero;
    }
    
    return CGSizeMake(_collectionView.collectionViewLayout.itemWidth, 60.0);
}

#pragma mark - MessageInputTextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
    
    [self _toggleSendButtonEnabled];
    
    if (_automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:YES];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self _toggleSendButtonEnabled];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (void)textViewDidChangeFrame:(UITextView *)textView delta:(CGFloat)delta
{
    [UIView animateWithDuration:0.2f animations:^{
        [self adjustInputToolbarHeightByDelta:delta];
        [self updateCollectionViewInsets];
        [self scrollToBottomAnimated:NO];
    } completion:nil];
    
    [self updateKeyboardTriggerPoint];
}

#pragma mark - Utility

- (void)updateCollectionViewInsets
{
    [self setCollectionViewInsetsTopValue:[self.topLayoutGuide length]
                              bottomValue:CGRectGetHeight(_collectionView.frame) - CGRectGetMinY(_messageInputView.frame)];
}

- (void)setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsMake(top, 0.0f, bottom, 0.0f);
    _collectionView.contentInset = insets;
    _collectionView.scrollIndicatorInsets = insets;
}

- (void)updateKeyboardTriggerPoint
{
    _keyboardController.keyboardTriggerPoint = CGPointMake(0.0f, CGRectGetHeight(_messageInputView.bounds));
}

- (void)adjustInputToolbarHeightByDelta:(CGFloat)dy
{
    CGRect frame = _messageInputView.frame;
    frame.origin.y -= dy;
    frame.size.height += dy;
    _messageInputView.frame = frame;
}

- (void)adjustInputToolbarBottomSpaceByDelta:(CGFloat)dy
{
    CGRect frame = _messageInputView.frame;
    frame.origin.y -= dy;
    _messageInputView.frame = frame;
}

#pragma mark - Keyboard

- (void)keyboardController:(InteractiveKeyboardController *)keyboardController keyboardDidChangeFrame:(CGRect)keyboardFrame
{
    CGFloat heightFromBottom = CGRectGetHeight(_collectionView.frame) - CGRectGetMinY(keyboardFrame);
    heightFromBottom = MAX(0.0f, heightFromBottom);

    CGRect frame = _messageInputView.frame;
    frame.origin.y = CGRectGetHeight(_collectionView.frame) - heightFromBottom - CGRectGetHeight(_messageInputView.frame);
    _messageInputView.frame = frame;
    
    [self updateCollectionViewInsets];
}

#pragma mark - Notifications

- (void)statusBarDidChangeFrame:(NSNotification *)notification
{
    if (self.keyboardController.keyboardIsVisible) {
        [self adjustInputToolbarBottomSpaceByDelta:CGRectGetHeight(self.keyboardController.currentKeyboardFrame)];
    }
}

@end
