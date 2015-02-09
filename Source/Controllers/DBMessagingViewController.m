//
//  DBMessagingViewController.m
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

#import "DBMessagingViewController.h"

#import "DBInteractiveKeyboardController.h"
#import "DBMessageBubbleController.h"
#import "DBMessagingInputTextView.h"
#import "DBMessagingInputToolbar.h"
#import "DBMessagingCollectionView.h"
#import "DBMessagingCollectionViewHiddenTimestampFlowLayout.h"
#import "DBMessagingCollectionViewSlidingTimestampFlowLayout.h"
#import "DBMessagingCollectionViewFlowLayoutInvalidationContext.h"
#import "DBMessagingTextCell.h"
#import "DBMessagingImageCell.h"
#import "DBMessagingLocationCell.h"
#import "DBMessagingMovieCell.h"
#import "DBMessagingTimestampSupplementaryView.h"
#import "DBMessagingLoadEarlierMessagesHeaderView.h"
#import "DBMessagingTypingIndicatorFooterView.h"

@interface DBMessagingViewController () <DBMessagingInputToolbarDelegate, DBInteractiveKeyboardControllerDelegate>

@property (strong, nonatomic) DBMessagingCollectionView *collectionView;
@property (strong, nonatomic) DBMessagingInputToolbar *messageInputToolbar;
@property (strong, nonatomic) DBInteractiveKeyboardController *keyboardController;

- (void)_finishSendingOrReceivingMessage;

@end

@implementation DBMessagingViewController

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [super loadView];
    
    DBMessagingCollectionViewBaseFlowLayout *collectionViewLayout = [[DBMessagingCollectionViewBaseFlowLayout alloc] init];
    _collectionView = [[DBMessagingCollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:collectionViewLayout];
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [self.view addSubview:_collectionView];
    
    _messageInputToolbar = [[DBMessagingInputToolbar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 50.0, CGRectGetWidth(self.view.frame), 50.0)];
    [_messageInputToolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [_messageInputToolbar setDelegate:self];
    [self.view addSubview:_messageInputToolbar];
    
    _keyboardController = [[DBInteractiveKeyboardController alloc] initWithTextView:_messageInputToolbar.textView
                                                                        contextView:self.view
                                                               panGestureRecognizer:_collectionView.panGestureRecognizer
                                                                           delegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarDidChangeFrame:)
                                                 name:UIApplicationDidChangeStatusBarFrameNotification
                                               object:nil];

    _automaticallyScrollsToMostRecentMessage = YES;
    _acceptsAutoCorrectBeforeSending = YES;
    
    [self updateCollectionViewInsets];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view layoutIfNeeded];
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToBottomAnimated:NO];
            [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
        });
    }
    
    [self updateKeyboardTriggerPoint];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_keyboardController beginListeningForKeyboard];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_keyboardController endListeningForKeyboard];
}

#pragma mark - Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_collectionView.collectionViewLayout invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

#pragma mark - Setters

- (void)setShowLoadMoreMessages:(BOOL)showLoadMoreMessages
{
    if (_showLoadMoreMessages == showLoadMoreMessages) {
        return;
    }
    
    _showLoadMoreMessages = showLoadMoreMessages;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)setShowTypingIndicator:(BOOL)showTypingIndicator
{
    if (_showTypingIndicator == showTypingIndicator) {
        return;
    }
    
    _showTypingIndicator = showTypingIndicator;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)setTimestampStyle:(DBMessagingTimestampStyle)timestampStyle {
    
    if (_timestampStyle == timestampStyle) {
        return;
    }
    
    _timestampStyle = timestampStyle;
    
    DBMessagingCollectionViewBaseFlowLayout *layout;
    
    switch (timestampStyle) {
        case DBMessagingTimestampStyleNone:
            layout = [[DBMessagingCollectionViewBaseFlowLayout alloc] init];
            break;
        case DBMessagingTimestampStyleHidden:
            layout = [[DBMessagingCollectionViewHiddenTimestampFlowLayout alloc] init];
            break;
        case DBMessagingTimestampStyleSliding:
            layout = [[DBMessagingCollectionViewSlidingTimestampFlowLayout alloc] init];
            break;
        default:
            break;
    }
    
    [_collectionView setCollectionViewLayout:layout];
}

#pragma mark - Public

- (void)finishReceivingMessage {
    self.showTypingIndicator = NO;
    [self _finishSendingOrReceivingMessage];
}

- (void)finishSendingMessage {
    [_messageInputToolbar.textView clear];
    [_messageInputToolbar toggleSendButtonEnabled];
    [self _finishSendingOrReceivingMessage];
}

- (NSIndexPath *)indexPathForLatestMessage {
    return [NSIndexPath indexPathForItem:[_collectionView numberOfItemsInSection:0] - 1 inSection:0];
}

// NOT WORKING RIGHT
- (void)scrollToBottomAnimated:(BOOL)animated {
    
    if ([self.collectionView numberOfSections] == 0) {
        return;
    }
    
    NSInteger items = [self.collectionView numberOfItemsInSection:0];
    
    if (items == 0) {
        return;
    }
    
    CGFloat collectionViewContentHeight = [self.collectionView.collectionViewLayout collectionViewContentSize].height;
    BOOL isContentTooSmall = (collectionViewContentHeight < CGRectGetHeight(self.collectionView.bounds));
    
    if (isContentTooSmall) {
        //  workaround for the first few messages not scrolling
        //  when the collection view content size is too small, `scrollToItemAtIndexPath:` doesn't work properly
        //  this seems to be a UIKit bug, see #256 on GitHub
        [self.collectionView scrollRectToVisible:CGRectMake(0.0, collectionViewContentHeight - 1.0f, 1.0f, 1.0f)
                                        animated:animated];
        return;
    }
    
    // Workaround for really long messages not scrolling properly
    CGSize finalCellSize = [self.collectionView.collectionViewLayout sizeForItemAtIndexPath:[self indexPathForLatestMessage]];
    
    CGFloat maxHeightForVisibleMessage = CGRectGetHeight(self.collectionView.bounds) - self.collectionView.contentInset.top - CGRectGetHeight(self.messageInputToolbar.bounds);
    
    UICollectionViewScrollPosition scrollPosition = (finalCellSize.height > maxHeightForVisibleMessage) ? UICollectionViewScrollPositionBottom : UICollectionViewScrollPositionTop;
    
    [self.collectionView scrollToItemAtIndexPath:[self indexPathForLatestMessage]
                                atScrollPosition:scrollPosition
                                        animated:animated];
}

#pragma mark - Private

- (void)_finishSendingOrReceivingMessage
{
    [_collectionView reloadData];
    
    [self updateCollectionViewInsets];

    if (_automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:YES];
    }
}

#pragma mark - DBMessagingCollectionViewDataSource

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

- (NSAttributedString *)collectionView:(UICollectionView *)collectionView messageTopLabelAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSAttributedString *)collectionView:(UICollectionView *)collectionView cellTopLabelAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSAttributedString *)collectionView:(UICollectionView *)collectionView cellBottomLabelAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(DBMessagingCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isOutgoingMessage = [[self collectionView:collectionView sentByUserIDForMessageAtIndexPath:indexPath] isEqualToString:[self senderUserID]];
    
    NSString *cellIdentifier;
    switch ([self collectionView:collectionView MIMETypeForMessageAtIndexPath:indexPath]) {
        case MIMETypeText: {
            cellIdentifier = DBMessagingTextCellIdentifier;
            break;
        }
        case MIMETypeImage: {
            cellIdentifier = DBMessagingImageCellIdentifier;
            break;
        }
        case MIMETypeLocation: {
            cellIdentifier = DBMessagingLocationCellIdentifier;
            break;
        }
        case MIMETypeGIF: {
            cellIdentifier = DBMessagingGIFCellIdentifier;
            break;
        }
        case MIMETypeMovie: {
            cellIdentifier = DBMessagingMovieCellIdentifier;
            break;
        }
        default:
            break;
    }
    
    DBMessagingParentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
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
            DBMessagingTextCell *textCell = (DBMessagingTextCell *)cell;
            NSString *messageText = [[NSString alloc] initWithData:[collectionView.dataSource collectionView:collectionView dataForMessageAtIndexPath:indexPath] encoding:NSUTF8StringEncoding];
            textCell.messageText = messageText;
            textCell.messageTextView.dataDetectorTypes = UIDataDetectorTypeAll;
            break;
        }
        case MIMETypeImage:{
            DBMessagingImageCell *imageCell = (DBMessagingImageCell *)cell;
            UIImage *image = [[UIImage alloc] initWithData:[collectionView.dataSource collectionView:collectionView dataForMessageAtIndexPath:indexPath]];
            if (image) {
                imageCell.imageView.image = image;
            }
            else {
                [collectionView.dataSource collectionView:collectionView wantsImageForImageView:imageCell.imageView atIndexPath:indexPath];
            }
            break;
        }
        case MIMETypeLocation: {
            DBMessagingLocationCell *locationCell = (DBMessagingLocationCell *)cell;
            CLLocation *location = [collectionView.dataSource collectionView:collectionView locationForMessageAtIndexPath:indexPath];
            [locationCell setLocation:location];
            break;
        }
        case MIMETypeGIF: {
            DBMessagingGIFCell *GIFCell = (DBMessagingGIFCell *)cell;
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
            DBMessagingMovieCell *movieCell = (DBMessagingMovieCell *)cell;
            movieCell.movieData = [collectionView.dataSource collectionView:collectionView dataForMessageAtIndexPath:indexPath];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(DBMessagingCollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    if (_showTypingIndicator && [kind isEqualToString:UICollectionElementKindSectionFooter]) {
        return [collectionView dequeueTypingIndicatorFooterViewForIndexPath:indexPath];
    }
    else if (_showLoadMoreMessages && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [collectionView dequeueLoadMoreHeaderViewForIndexPath:indexPath];
    }
    else if ([kind isEqualToString:DBMessagingCollectionElementKindTimestamp]) {
        DBMessagingTimestampSupplementaryView *supplementaryView = (DBMessagingTimestampSupplementaryView *)[collectionView dequeueTimestampSupplementaryViewForIndexPath:indexPath];
        
        NSString *sentByUserID = [self collectionView:collectionView sentByUserIDForMessageAtIndexPath:indexPath];
        
        supplementaryView.timestampLabel.attributedText = [collectionView.dataSource collectionView:collectionView timestampAttributedTextForSupplementaryViewAtIndexPath:indexPath];
        supplementaryView.type = ([sentByUserID isEqualToString:[self senderUserID]]) ? MessageBubbleTypeOutgoing : MessageBubbleTypeIncoming;
        supplementaryView.timestampStyle = _timestampStyle;
        
        return supplementaryView;
    }
    
    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout

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

#pragma mark - DBMessagingInputToolbarDelegate

- (void)messagingInputToolbar:(DBMessagingInputToolbar *)toolbar shouldChangeFrame:(CGFloat)change {
    [self adjustInputToolbarHeightByDelta:change];
    [self updateCollectionViewInsets];
    
    if (_automaticallyScrollsToMostRecentMessage) {
        [self.collectionView scrollToItemAtIndexPath:[self indexPathForLatestMessage]
                                    atScrollPosition:UICollectionViewScrollPositionBottom
                                            animated:NO];
    }
    
    [self updateKeyboardTriggerPoint];
}

- (void)messagingInputToolbarDidBeginEditing:(DBMessagingInputToolbar *)toolbar {
    [_messageInputToolbar toggleSendButtonEnabled];
    
    if (_automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:YES];
    }
    
    [self updateCollectionViewInsets];
}

#pragma mark - Utility

- (void)updateCollectionViewInsets {
    [self setCollectionViewInsetsTopValue:[self.topLayoutGuide length]
                              bottomValue:CGRectGetHeight(_collectionView.frame) - CGRectGetMinY(_messageInputToolbar.frame)];
}

- (void)setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsMake(top, 0.0f, bottom, 0.0f);
    _collectionView.contentInset = insets;
    _collectionView.scrollIndicatorInsets = insets;
}

- (void)updateKeyboardTriggerPoint {
    _keyboardController.keyboardTriggerPoint = CGPointMake(0.0f, CGRectGetHeight(_messageInputToolbar.bounds));
}

- (void)adjustInputToolbarHeightByDelta:(CGFloat)dy {
    CGRect frame = _messageInputToolbar.frame;
    frame.origin.y -= dy;
    frame.size.height += dy;
    _messageInputToolbar.frame = frame;
}

- (void)adjustInputToolbarBottomSpaceByDelta:(CGFloat)dy {
    CGRect frame = _messageInputToolbar.frame;
    frame.origin.y -= dy;
    _messageInputToolbar.frame = frame;
}

#pragma mark - Keyboard

- (void)keyboardController:(DBInteractiveKeyboardController *)keyboardController keyboardDidChangeFrame:(CGRect)keyboardFrame {
    CGFloat heightFromBottom = CGRectGetHeight(_collectionView.frame) - CGRectGetMinY(keyboardFrame);
    heightFromBottom = MAX(0.0f, heightFromBottom);

    CGRect frame = _messageInputToolbar.frame;
    frame.origin.y = CGRectGetHeight(_collectionView.frame) - heightFromBottom - CGRectGetHeight(_messageInputToolbar.frame);
    _messageInputToolbar.frame = frame;
    
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
