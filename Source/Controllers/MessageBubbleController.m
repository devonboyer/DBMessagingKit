//
//  MessageBubbleController.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-10-14.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "MessageBubbleController.h"

#import "UIColor+Messaging.h"
#import "MessageBubbleFactory.h"
#import "MessagingCollectionView.h"

@interface MessageBubbleController ()

@property (strong, nonatomic) NSMutableArray *messageGroupIndexPaths;

@property (weak, nonatomic) MessagingCollectionView *collectionView;

@property (strong, nonatomic) UIImageView *incomingTopMessageBubble;
@property (strong, nonatomic) UIImageView *incomingMiddleMessageBubble;
@property (strong, nonatomic) UIImageView *incomingBottonMessageBubble;
@property (strong, nonatomic) UIImageView *incomingDefaultMessageBubble;

@property (strong, nonatomic) UIImageView *outgoingTopMessageBubble;
@property (strong, nonatomic) UIImageView *outgoingMiddleMessageBubble;
@property (strong, nonatomic) UIImageView *outgoingBottomMessageBubble;
@property (strong, nonatomic) UIImageView *outgoingDefaultMessageBubble;

@end

@implementation MessageBubbleController

- (instancetype)initWithCollectionView:(MessagingCollectionView *)collectionView
{
    NSParameterAssert(collectionView);
    NSParameterAssert([collectionView isKindOfClass:[MessagingCollectionView class]]);
    
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        self.incomingMessageBubbleColor = [UIColor iMessageGrayColor];
        self.outgoingMessageBubbleColor = [UIColor iMessageBlueColor];
    }
    return self;
}

- (instancetype)initWithCollectionView:(MessagingCollectionView *)collectionView outgoingBubbleColor:(UIColor *)outgoingMessageBubbleColor incomingBubbleColor:(UIColor *)incomingMessageBubbleColor
{
    NSParameterAssert(collectionView);
    NSParameterAssert([collectionView isKindOfClass:[MessagingCollectionView class]]);
    
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        self.incomingMessageBubbleColor = incomingMessageBubbleColor;
        self.outgoingMessageBubbleColor = outgoingMessageBubbleColor;
    }
    return self;
}

- (void)setTopTemplateForConsecutiveGroup:(UIImage *)templateImage
{
    NSParameterAssert(templateImage);
    
    self.incomingTopMessageBubble = [MessageBubbleFactory incomingMessageBubbleImageWithColor:self.incomingMessageBubbleColor
                                                                               template:templateImage];
    self.outgoingTopMessageBubble = [MessageBubbleFactory outgoingMessageBubbleImageWithColor:self.outgoingMessageBubbleColor
                                                                               template:templateImage];
}

- (void)setMiddleTemplateForConsecutiveGroup:(UIImage *)templateImage
{
    NSParameterAssert(templateImage);
    
    self.incomingMiddleMessageBubble = [MessageBubbleFactory incomingMessageBubbleImageWithColor:self.incomingMessageBubbleColor
                                                                                  template:templateImage];
    self.outgoingMiddleMessageBubble = [MessageBubbleFactory outgoingMessageBubbleImageWithColor:self.outgoingMessageBubbleColor
                                                                                  template:templateImage];
}

- (void)setBottomTemplateForConsecutiveGroup:(UIImage *)templateImage
{
    NSParameterAssert(templateImage);
    
    self.incomingBottonMessageBubble = [MessageBubbleFactory incomingMessageBubbleImageWithColor:self.incomingMessageBubbleColor
                                                                                  template:templateImage];
    self.outgoingBottomMessageBubble = [MessageBubbleFactory outgoingMessageBubbleImageWithColor:self.outgoingMessageBubbleColor
                                                                                  template:templateImage];
}

- (void)setDefaultTemplate:(UIImage *)templateImage
{
    NSParameterAssert(templateImage);
    
    self.incomingDefaultMessageBubble = [MessageBubbleFactory incomingMessageBubbleImageWithColor:self.incomingMessageBubbleColor
                                                                               template:templateImage];
    self.outgoingDefaultMessageBubble = [MessageBubbleFactory outgoingMessageBubbleImageWithColor:self.outgoingMessageBubbleColor
                                                                               template:templateImage];
}

#pragma mark - Public

- (UIImageView *)messageBubbleForIndexPath:(NSIndexPath *)indexPath
{
    
    NSAssert(self.outgoingDefaultMessageBubble &&
            self.incomingDefaultMessageBubble, @"Error: default message bubble cannot be nil");
    
    NSIndexPath *beforeIndexPath = [NSIndexPath indexPathForItem:indexPath.row - 1 inSection:indexPath.section];
    NSIndexPath *afterIndexPath = [NSIndexPath indexPathForItem:indexPath.row + 1 inSection:indexPath.section];
    
    NSString *sentByUserID = [_collectionView.dataSource collectionView:_collectionView sentByUserIDForMessageAtIndexPath:indexPath];
    
    NSInteger numberOfItems = [_collectionView.dataSource collectionView:_collectionView numberOfItemsInSection:indexPath.section];
    
    BOOL isOutgoing = [sentByUserID isEqualToString:[_collectionView.dataSource senderUserID]];
    
    if (numberOfItems < 2) {
        return isOutgoing ? self.outgoingDefaultMessageBubble : self.incomingDefaultMessageBubble;
    }
    else if (indexPath.row == 0) {
        
        NSString *afterSentByUserID = [_collectionView.dataSource collectionView:_collectionView sentByUserIDForMessageAtIndexPath:afterIndexPath];
        
        if ([afterSentByUserID isEqualToString:sentByUserID]) {
            
            // If the top is not set, next logical choice is middle, otherwise default
            if (self.outgoingTopMessageBubble && self.incomingTopMessageBubble) {
                return isOutgoing ? self.outgoingTopMessageBubble : self.incomingTopMessageBubble;
            }
            else {
                return isOutgoing ? self.outgoingDefaultMessageBubble : self.incomingDefaultMessageBubble;
            }
        }
        
        if (![afterSentByUserID isEqualToString:sentByUserID]) {
            return isOutgoing ? self.outgoingDefaultMessageBubble : self.incomingDefaultMessageBubble;
        }

    }
    else if (indexPath.row == numberOfItems - 1) {
        
        NSString *beforeSentByUserID = [_collectionView.dataSource collectionView:_collectionView sentByUserIDForMessageAtIndexPath:beforeIndexPath];
        
        if ([beforeSentByUserID isEqualToString:sentByUserID]) {
            
            if (self.outgoingTopMessageBubble && self.incomingTopMessageBubble) {
                return isOutgoing ? self.outgoingBottomMessageBubble : self.incomingBottonMessageBubble;
            }
            else {
                return isOutgoing ? self.outgoingDefaultMessageBubble : self.incomingDefaultMessageBubble;
            }
        }
        
        if (![beforeSentByUserID isEqualToString:sentByUserID]) {
            return isOutgoing ? self.outgoingDefaultMessageBubble : self.incomingDefaultMessageBubble;
        }
    }
    else {
        NSString *afterSentByUserID = [_collectionView.dataSource collectionView:_collectionView sentByUserIDForMessageAtIndexPath:afterIndexPath];
        NSString *beforeSentByUserID = [_collectionView.dataSource collectionView:_collectionView sentByUserIDForMessageAtIndexPath:beforeIndexPath];
        
        if ([afterSentByUserID isEqualToString:sentByUserID] && ![beforeSentByUserID isEqualToString:sentByUserID]) {
            
            // If the top is not set, next logical choice is middle, otherwise default
            if (self.outgoingTopMessageBubble && self.incomingTopMessageBubble) {
                return isOutgoing ? self.outgoingTopMessageBubble : self.incomingTopMessageBubble;
            }
            else {
                return isOutgoing ? self.outgoingDefaultMessageBubble : self.incomingDefaultMessageBubble;
            }
        }
        
        if ([afterSentByUserID isEqualToString:sentByUserID] && [beforeSentByUserID isEqualToString:sentByUserID]) {
            
            if (self.outgoingMiddleMessageBubble && self.incomingMiddleMessageBubble) {
                return isOutgoing ? self.outgoingMiddleMessageBubble : self.incomingMiddleMessageBubble;
            }
            else {
                return isOutgoing ? self.outgoingDefaultMessageBubble : self.incomingDefaultMessageBubble;
            }
        }
        
        if (![afterSentByUserID isEqualToString:sentByUserID] && [beforeSentByUserID isEqualToString:sentByUserID]) {
            
            if (self.outgoingBottomMessageBubble && self.incomingBottonMessageBubble) {
                return isOutgoing ? self.outgoingBottomMessageBubble : self.incomingBottonMessageBubble;
            }
            else {
                return isOutgoing ? self.outgoingDefaultMessageBubble : self.incomingDefaultMessageBubble;
            }
        }
    }
    
    return isOutgoing ? self.outgoingDefaultMessageBubble : self.incomingDefaultMessageBubble;
}

- (void)beginMessageGroupAtIndexPath:(NSIndexPath *)indexPath {
    [_messageGroupIndexPaths addObject:indexPath];
}

@end
