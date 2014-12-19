//
//  MessagingTextCell.m
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-10-10.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingTextCell.h"

#import "UIColor+Messaging.h"

#import "MessagingCellTextView.h"
#import "MessagingCollectionView.h"
#import "MessagingCollectionViewFlowLayout.h"
#import "MessagingCollectionViewLayoutAttributes.h"

@interface MessagingTextCell () <UIGestureRecognizerDelegate, UITextViewDelegate>

@property (strong, nonatomic) UITextView *messageTextView;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;
@property (strong, nonatomic) UITapGestureRecognizer *messageTextViewTap;

@end

@implementation MessagingTextCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _messageTextView = [[MessagingCellTextView alloc] init];
        [_messageTextView setDelegate:self];
        [_messageTextView setFrame:self.messageBubbleImageView.frame];
        [_messageTextView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.messageBubbleImageView addSubview:self.messageTextView];
        
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        _longPress.minimumPressDuration = 0.5f;
        [self addGestureRecognizer:_longPress];
        
        _messageTextViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMessageTextViewTap:)];
        [_messageTextViewTap setDelegate:self];
        [self.messageTextView addGestureRecognizer:_messageTextViewTap];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applyLayoutAttributes:(MessagingCollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    self.messageTextView.font = layoutAttributes.messageBubbleFont;
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.messageTextView.textContainerInset, layoutAttributes.messageBubbleTextViewTextContainerInsets)) {
        self.messageTextView.textContainerInset = layoutAttributes.messageBubbleTextViewTextContainerInsets;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.messageTextView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.messageTextView.text = nil;
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.messageTextView.text];
    [self resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
    }
}

#pragma mark - Setters

- (void)setType:(MessageBubbleType)type
{
    [super setType:type];
    
    switch (self.type) {
        case MessageBubbleTypeIncoming: {
            [self.messageTextView setTextColor:[UIColor blackColor]];
            [_messageTextView setLinkTextAttributes:@{
                NSForegroundColorAttributeName : [UIColor blackColor],
                NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid)}];
            break;
        }
        case MessageBubbleTypeOutgoing: {
            [self.messageTextView setTextColor:[UIColor whiteColor]];
            [_messageTextView setLinkTextAttributes:@{
                NSForegroundColorAttributeName : [UIColor whiteColor],
                NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid)}];
            break;
        }
        default:
            break;
    }
    
    [self layoutSubviews];
}

- (void)setMessageText:(NSString *)messageText
{
    _messageText = messageText;
    self.messageTextView.text = [messageText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - Actions

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder]) {
        return;
    }
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    CGRect targetRect = [self convertRect:self.messageBubbleImageView.bounds fromView:self.messageBubbleImageView];
    
    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
    
    self.messageBubbleImageView.highlighted = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuWillShow:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:menu];
    
    [menu setMenuVisible:YES animated:YES];
}

- (void)handleMessageTextViewTap:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(messageCell:didTapMessageBubbleImageView:)]) {
        [self.delegate messageCell:self didTapMessageBubbleImageView:self.messageBubbleImageView];
    }
    
    CGPoint tapPoint = [tap locationInView:self.collectionView];
    NSIndexPath *tappedIndexPath = [self.collectionView indexPathForItemAtPoint:tapPoint];
    MessagingCollectionViewFlowLayout *collectionViewLayout = (MessagingCollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectionViewLayout.tappedIndexPath = tappedIndexPath;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return otherGestureRecognizer == _longPress;
}

#pragma mark - Notifications

- (void)menuWillHide:(NSNotification *)notification
{
    self.messageBubbleImageView.highlighted = NO;
   // _messageTextView.selectable = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
}

- (void)menuWillShow:(NSNotification *)notification
{
    //  textviews are selectable to allow data detectors
    //  however, this allows the 'copy, define, select' UIMenuController to show
    //  which conflicts with the collection view's UIMenuController
    //  temporarily disable 'selectable' to prevent this issue
    _messageTextView.selectable = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuWillHide:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:[notification object]];
}

@end
