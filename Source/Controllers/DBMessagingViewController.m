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
#import "DBMessageInputToolbar.h"
#import "DBMessagingCollectionView.h"
#import "DBMessagingCollectionViewFlowLayout.h"
#import "DBMessagingCollectionViewFlowLayoutInvalidationContext.h"
#import "DBMessagingTextCell.h"
#import "DBMessagingImageCell.h"
#import "DBMessagingLocationCell.h"
#import "DBMessagingMovieCell.h"
#import "DBMessagingTimestampSupplementaryView.h"
#import "DBMessagingLoadEarlierMessagesHeaderView.h"
#import "DBMessagingTypingIndicatorFooterView.h"

@interface DBMessagingViewController () <DBMessagingInputTextViewDelegate, DBInteractiveKeyboardControllerDelegate>

@property (strong, nonatomic) DBMessagingCollectionView *collectionView;
@property (strong, nonatomic) DBMessageInputToolbar *messageInputToolbar;
@property (strong, nonatomic) DBInteractiveKeyboardController *keyboardController;

- (void)_finishSendingOrReceivingMessage;

@end

@implementation DBMessagingViewController

- (void)loadView
{
    [super loadView];
    
    DBMessagingCollectionViewFlowLayout *collectionViewLayout = [[DBMessagingCollectionViewFlowLayout alloc] init];
    _collectionView = [[DBMessagingCollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:collectionViewLayout];
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [self.view addSubview:_collectionView];
    
    _messageInputToolbar = [[DBMessageInputToolbar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 50.0, CGRectGetWidth(self.view.frame), 50.0)];
    [_messageInputToolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [_messageInputToolbar.textView setDelegate:self];
    [self.view addSubview:_messageInputToolbar];
    
    _keyboardController = [[DBInteractiveKeyboardController alloc] initWithTextView:_messageInputToolbar.textView
                                                                        contextView:self.view
                                                               panGestureRecognizer:_collectionView.panGestureRecognizer
                                                                           delegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _automaticallyScrollsToMostRecentMessage = YES;
    _acceptsAutoCorrectBeforeSending = YES;
    
    [self updateCollectionViewInsets];
    [_messageInputToolbar toggleSendButtonEnabled];
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
    [_collectionView.collectionViewLayout invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
    
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
    
    if (_showTypingIndicator == showTypingIndicator) {
        return;
    }
    
    _showTypingIndicator = showTypingIndicator;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Public

- (void)sendMessageWithData:(NSData *)data MIMEType:(MIMEType)MIMEType {


}

- (void)sendCurrentlyComposedText {
    NSString *text = [_messageInputToolbar textView].text;
    
    if (_acceptsAutoCorrectBeforeSending) {
        // Accept any auto-correct suggestions before sending.
        text = [text stringByAppendingString:@" "];
    }
    
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [_messageInputToolbar.textView clear];
    
    [self sendMessageWithData:[text dataUsingEncoding:NSUTF8StringEncoding] MIMEType:MIMETypeText];
}

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


- (void)_finishSendingOrReceivingMessage
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
        DBMessagingParentCell *cell = (DBMessagingParentCell *)[_collectionView cellForItemAtIndexPath: indexPath];
        cell.messageBubbleImageView.image = [_collectionView.dataSource collectionView:_collectionView messageBubbleForItemAtIndexPath:indexPath].image;
        cell.messageBubbleImageView.highlightedImage = [_collectionView.dataSource collectionView:_collectionView messageBubbleForItemAtIndexPath:indexPath].highlightedImage;
        
        // Re-apply mask to image cells
        if ([cell isKindOfClass:[DBMessagingImageCell class]]) {
            [((DBMessagingImageCell *)cell).imageView setImage:((DBMessagingImageCell *)cell).imageView.image];
        }
    }
    
    [self updateCollectionViewInsets];
    
    if (_automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:YES];
    }
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

- (CLLocation *)collectionView:(UICollectionView *)collectionView locationForMessageAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)collectionView:(DBMessagingCollectionView *)collectionView wantsAvatarForImageView:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath { }

- (void)collectionView:(DBMessagingCollectionView *)collectionView wantsImageForImageView:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath { }

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(DBMessagingCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
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
                                 atIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark - DBMessageInputTextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
    
    [_messageInputToolbar toggleSendButtonEnabled];
    
    if (_automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:YES];
    }
    
    [self updateCollectionViewInsets];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [_messageInputToolbar toggleSendButtonEnabled];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (void)textViewDidChangeFrame:(UITextView *)textView delta:(CGFloat)delta
{
    [self adjustInputToolbarHeightByDelta:delta];
    [self updateCollectionViewInsets];
    
    if (_automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:NO];
    }
    
    [self updateKeyboardTriggerPoint];
}

#pragma mark - Utility

- (void)updateCollectionViewInsets
{
    [self setCollectionViewInsetsTopValue:[self.topLayoutGuide length]
                              bottomValue:CGRectGetHeight(_collectionView.frame) - CGRectGetMinY(_messageInputToolbar.frame)];
}

- (void)setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsMake(top, 0.0f, bottom, 0.0f);
    _collectionView.contentInset = insets;
    _collectionView.scrollIndicatorInsets = insets;
}

- (void)updateKeyboardTriggerPoint
{
    _keyboardController.keyboardTriggerPoint = CGPointMake(0.0f, CGRectGetHeight(_messageInputToolbar.bounds));
}

- (void)adjustInputToolbarHeightByDelta:(CGFloat)dy
{
    CGRect frame = _messageInputToolbar.frame;
    frame.origin.y -= dy;
    frame.size.height += dy;
    _messageInputToolbar.frame = frame;
}

- (void)adjustInputToolbarBottomSpaceByDelta:(CGFloat)dy
{
    CGRect frame = _messageInputToolbar.frame;
    frame.origin.y -= dy;
    _messageInputToolbar.frame = frame;
}

#pragma mark - Keyboard

- (void)keyboardController:(DBInteractiveKeyboardController *)keyboardController keyboardDidChangeFrame:(CGRect)keyboardFrame
{
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
