//
//  MessagingViewController.m
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-10-12.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingViewController.h"

#import "InteractiveKeyboardController.h"
#import "MessageBubbleController.h"
#import "MessagingInputTextView.h"
#import "MessagingCollectionView.h"
#import "MessagingCollectionViewFlowLayout.h"
#import "MessagingCollectionViewFlowLayoutInvalidationContext.h"
#import "MessagingTextCell.h"
#import "MessagingImageCell.h"
#import "MessagingLocationCell.h"
#import "MessagingMovieCell.h"
#import "MessagingTimestampSupplementaryView.h"
#import "MessagingLoadEarlierMessagesHeaderView.h"
#import "MessagingTypingIndicatorFooterView.h"

@interface MessagingViewController () <MessagingInputTextViewDelegate, InteractiveKeyboardControllerDelegate>

@property (strong, nonatomic) MessagingCollectionView *collectionView;
@property (strong, nonatomic) UIView<MessagingInputUtility> *messageInputView;
@property (strong, nonatomic) InteractiveKeyboardController *keyboardController;

- (void)_messageInputView:(UIView<MessagingInputUtility> *)chatInputView sendButtonTapped:(UIButton *)sendButton;

- (void)_beginSendingOrFinishReceivingMessage;
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
    
    _currentlySendingMessageIndexPaths = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _automaticallyScrollsToMostRecentMessage = YES;
    _acceptsAutoCorrectBeforeSending = YES;
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

#pragma mark - Public

- (void)sendMessageWithData:(NSData *)data MIMEType:(MIMEType)MIMEType { }

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

- (void)beginSendingMessage {
    [self _clearCurrentlyComposedText];
    [self _toggleSendButtonEnabled];

    NSUInteger previousNumberOfMessages = [_collectionView numberOfItemsInSection:0];
    NSIndexPath *lastMessageIndexPath = [NSIndexPath indexPathForRow:previousNumberOfMessages inSection:0];
    
    // Insert the new message
    [self _beginSendingOrFinishReceivingMessage];
    
    [_currentlySendingMessageIndexPaths addObject:lastMessageIndexPath];
    [self updateMessageSendingProgress:0.2 forItemAtIndexPath:lastMessageIndexPath];
}

- (void)updateMessageSendingProgress:(CGFloat)progress forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (progress < 0.2) progress = 0.2;
    if (progress > 1) progress = 1;
    
    MessagingParentCell *cell = (MessagingParentCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    cell.messageBubbleImageView.alpha = progress;
    
    if (progress == 1.0) {
        [self finishSendingMessageAtIndexPath:indexPath];
    }
}

- (void)finishSendingMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        MessagingParentCell *cell = (MessagingParentCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        cell.messageBubbleImageView.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [_currentlySendingMessageIndexPaths removeObject:indexPath];
        }
    }];
}

- (void)finishSendingAllMessages {
    for (NSIndexPath *indexPath in _currentlySendingMessageIndexPaths) {
        [self finishSendingMessageAtIndexPath:indexPath];
    }
}

- (NSIndexPath *)indexPathForLatestMessage {
    return [NSIndexPath indexPathForItem:[_collectionView numberOfItemsInSection:0] - 1 inSection:0];
}

- (void)finishReceivingMessage
{
    self.showTypingIndicator = NO;
    
    [self _beginSendingOrFinishReceivingMessage];
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    if ([_collectionView numberOfSections] == 0) {
        return;
    }
    
    NSInteger items = [_collectionView numberOfItemsInSection:0];
    
    if (items > 0) {
        [_collectionView scrollToItemAtIndexPath:[self indexPathForLatestMessage]
                                atScrollPosition:UICollectionViewScrollPositionTop
                                        animated:animated];
    }
}

#pragma mark - Private

- (void)_configureKeyboardController
{
    _keyboardController = [[InteractiveKeyboardController alloc] initWithTextView:_messageInputView.textView
                                                                      contextView:self.view
                                                             panGestureRecognizer:_collectionView.panGestureRecognizer
                                                                         delegate:self];
}

- (void)_beginSendingOrFinishReceivingMessage
{
    NSUInteger previousNumberOfMessages = [_collectionView numberOfItemsInSection:0];
    NSIndexPath *lastMessageIndexPath = [NSIndexPath indexPathForRow:previousNumberOfMessages inSection:0];
    
    // Insert the new message
    [_collectionView performBatchUpdates:^{
         [_collectionView insertItemsAtIndexPaths:@[lastMessageIndexPath]];
    } completion:nil];
    
    // Request a new message bubble form the data source
    for (NSInteger i = previousNumberOfMessages - 3; i < previousNumberOfMessages; ++i) {
        if (i < 0) continue;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        MessagingParentCell *cell = (MessagingParentCell *)[_collectionView cellForItemAtIndexPath: indexPath];
        cell.messageBubbleImageView.image = [_collectionView.dataSource collectionView:_collectionView messageBubbleForItemAtIndexPath:indexPath].image;
        cell.messageBubbleImageView.highlightedImage = [_collectionView.dataSource collectionView:_collectionView messageBubbleForItemAtIndexPath:indexPath].highlightedImage;
        
        // Re-apply mask to image cells
        if ([cell isKindOfClass:[MessagingImageCell class]]) {
            [((MessagingImageCell *)cell).imageView setImage:((MessagingImageCell *)cell).imageView.image];
        }
    }
    
    [self updateCollectionViewInsets];
    
    if (_automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:YES];
    }
}

- (void)_messageInputView:(UIView<MessagingInputUtility> *)messageInputView sendButtonTapped:(UIButton *)sendButton
{
    if ([self _currentlyComposedText].length > 0) {
        [self sendMessageWithData:[[self _currentlyComposedText] dataUsingEncoding:NSUTF8StringEncoding] MIMEType:MIMETypeText];
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

- (MIMEType)collectionView:(UICollectionView *)collectionView MIMETypeForMessageAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return 0;
}

- (NSData *)collectionView:(UICollectionView *)collectionView dataForMessageAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (CLLocation *)collectionView:(UICollectionView *)collectionView locationForMessageAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
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

- (void)collectionView:(MessagingCollectionView *)collectionView wantsImageForImageView:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath { }

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
            cellIdentifier = kMessagingImageCellIdentifier;
            break;
        }
        case MIMETypeLocation: {
            cellIdentifier = kMessagingLocationCellIdentifier;
            break;
        }
        case MIMETypeGIF: {
            cellIdentifier = kMessagingGIFCellIdentifier;
            break;
        }
        case MIMETypeMovie: {
            cellIdentifier = kMessagingMovieCellIdentifier;
            break;
        }
        default:
            break;
    }
    
    MessagingParentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = collectionView;
    cell.collectionView = collectionView;
    cell.type = (isOutgoingMessage) ? MessageBubbleTypeOutgoing : MessageBubbleTypeIncoming;
    
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
            MessagingImageCell *imageCell = (MessagingImageCell *)cell;
            UIImage *image = [[UIImage alloc] initWithData:[self collectionView:collectionView dataForMessageAtIndexPath:indexPath]];
            if (image) {
                imageCell.imageView.image = image;
            }
            else {
                [collectionView.dataSource collectionView:collectionView wantsImageForImageView:imageCell.imageView atIndexPath:indexPath];
            }
            break;
        }
        case MIMETypeLocation: {
            MessagingLocationCell *locationCell = (MessagingLocationCell *)cell;
            CLLocation *location = [collectionView.dataSource collectionView:collectionView locationForMessageAtIndexPath:indexPath];
            [locationCell setLocation:location];
            break;
        }
        case MIMETypeGIF: {
            MessagingGIFCell *GIFCell = (MessagingGIFCell *)cell;
            NSData *GIFData = [collectionView.dataSource collectionView:collectionView dataForMessageAtIndexPath:indexPath];
            if (GIFData) {
                GIFCell.animatedGIFData = GIFData;
            }
            else {
               [collectionView.dataSource collectionView:collectionView wantsImageForImageView:GIFCell.imageView atIndexPath:indexPath];
            }
            break;
        }
        case MIMETypeMovie: {
            MessagingMovieCell *movieCell = (MessagingMovieCell *)cell;
            movieCell.movieData = [collectionView.dataSource collectionView:collectionView dataForMessageAtIndexPath:indexPath];
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
        supplementaryView.type = ([sentByUserID isEqualToString:[self senderUserID]]) ? MessageBubbleTypeOutgoing : MessageBubbleTypeIncoming;
        
        return supplementaryView;
    }
    
    return nil;
}

#pragma mark - MessagingCollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath { }

- (void)collectionView:(UICollectionView *)collectionView didTapImageView:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath { }

- (void)collectionView:(UICollectionView *)collectionView didTapMessageBubbleImageView:(UIImageView *)messageBubbleImageView atIndexPath:(NSIndexPath *)indexPath { }

- (void)collectionView:(UICollectionView *)collectionView didTapMoviePlayer:(MPMoviePlayerController *)moviePlayer atIndexPath:(NSIndexPath *)indexPath { }

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath];
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
    
    [self updateCollectionViewInsets];
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
    [UIView animateWithDuration:0.1 animations:^{
        [self adjustInputToolbarHeightByDelta:delta];
        [self updateCollectionViewInsets];
        
        if (_automaticallyScrollsToMostRecentMessage) {
            [self scrollToBottomAnimated:NO];
        }
        
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
