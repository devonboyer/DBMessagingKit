//
//  DBMessagingCollectionViewSlidingTimestampFlowLayout.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2015-02-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingCollectionViewSlidingTimestampFlowLayout.h"

#import "DBMessagingCollectionViewLayoutAttributes.h"
#import "DBMessagingCollectionViewFlowLayoutInvalidationContext.h"
#import "DBMessagingCollectionView.h"
#import "NSAttributedString+Messaging.h"

@interface DBMessagingCollectionViewSlidingTimestampFlowLayout () <UIGestureRecognizerDelegate>

@end

@implementation DBMessagingCollectionViewSlidingTimestampFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [super commonInit];
    
    // Add an aditional pan gesture to the collection view
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panGesture.delegate = self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self.collectionView addGestureRecognizer:_panGesture];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *superAttrributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *attributesInRect = [superAttrributes mutableCopy];
    
    for (UICollectionViewLayoutAttributes *attributes in superAttrributes) {
        [attributesInRect addObject:[self layoutAttributesForSupplementaryViewOfKind:DBMessagingCollectionElementKindTimestamp atIndexPath:attributes.indexPath]];
    }
    
    // Move the cells
    if (_panning) {
        [attributesInRect enumerateObjectsUsingBlock:^(DBMessagingCollectionViewLayoutAttributes *layoutAttributes, NSUInteger idx, BOOL *stop) {
            
            CGFloat change = _startLocation.x - _panLocation.x;
            CGFloat maxChange = self.messageBubbleLeftRightMargin - self.sectionInset.left;
            CGRect frame = layoutAttributes.frame;
            
            change /= 2.0;
            
            if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
                if ([self isOutgoingMessageAtIndexPath:layoutAttributes.indexPath]) {
                    if (change <= maxChange) {
                        frame.origin.x = MIN(-change + self.sectionInset.left, self.sectionInset.left);
                    } else {
                        frame.origin.x = -maxChange + self.sectionInset.left;
                    }
                    
                } else if (!CGSizeEqualToSize([self avatarSizeForIndexPath:layoutAttributes.indexPath], CGSizeZero)){
                    // If incoming avatar's size is greater than zero, they also slide just enough to hide the avatars.
                    
                    change /= (maxChange / ([self avatarSizeForIndexPath:layoutAttributes.indexPath].width + self.incomingMessageBubbleAvatarSpacing));
                    maxChange = [self avatarSizeForIndexPath:layoutAttributes.indexPath].width + self.incomingMessageBubbleAvatarSpacing;
                    
                    if (change <= maxChange) {
                        frame.origin.x = MIN(-change + self.sectionInset.left, self.sectionInset.left);
                    } else {
                        frame.origin.x = -maxChange + self.sectionInset.left;
                    }
                    
                    change /= (maxChange / abs(self.sectionInset.left - self.incomingMessageBubbleAvatarSpacing));
                    maxChange = [self avatarSizeForIndexPath:layoutAttributes.indexPath].width + self.sectionInset.left;
                    layoutAttributes.slidingTimestampAvatarDistance = MIN(change, maxChange);
                }
                
                layoutAttributes.slidingTimestampDistance = MAX(MIN(change, maxChange), 0);
                
            } else if (layoutAttributes.representedElementCategory == UICollectionElementCategorySupplementaryView) {
                if (layoutAttributes.representedElementKind == DBMessagingCollectionElementKindTimestamp) {
                    CGFloat max = self.collectionView.frame.size.width;
                    CGFloat relativeWidth = self.collectionView.frame.size.width - self.sectionInset.right;
                    if (change < maxChange) {
                        frame.origin.x = MIN(relativeWidth - change, max);
                    } else {
                        frame.origin.x = MIN(relativeWidth - maxChange, max);
                    }
                }
            }
            
            layoutAttributes.frame = frame;
        }];
    }
    
    return attributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    DBMessagingCollectionViewLayoutAttributes *layoutAttributes = [DBMessagingCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    
    if (layoutAttributes) {
        
        DBMessagingCollectionViewLayoutAttributes *cellAttributes = (DBMessagingCollectionViewLayoutAttributes *)[self layoutAttributesForItemAtIndexPath:indexPath];
        CGRect cellFrame = cellAttributes.frame;
        
        if ([elementKind isEqualToString:DBMessagingCollectionElementKindTimestamp]) {
            layoutAttributes.frame = CGRectMake(self.collectionView.bounds.size.width, cellFrame.origin.y, self.messageBubbleLeftRightMargin, cellFrame.size.height);
            layoutAttributes.cellTopLabelHeight = cellAttributes.cellTopLabelHeight;
            layoutAttributes.messageBubbleTopLabelHeight = cellAttributes.messageBubbleTopLabelHeight;
        }
    }
    
    return layoutAttributes;
}

#pragma mark - Gestures

- (void)handlePan:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint velocity = [panGesture velocityInView:panGesture.view];
    CGPoint cvVelocity = [self.collectionView.panGestureRecognizer velocityInView:panGesture.view];

    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
        if (velocity.x < 0 && abs(cvVelocity.y) < 30.0) {
            _startLocation = [panGesture locationInView:self.collectionView];
            _panning = true;
        }
    }
    
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint panLocation = [panGesture locationInView:self.collectionView];

        if (panLocation.x == _panLocation.x) {
            return;
        }
        
        _panLocation = panLocation;
        [self invalidateLayout];
    }
    
    if (panGesture.state == UIGestureRecognizerStateEnded ||
        panGesture.state == UIGestureRecognizerStateCancelled ||
        panGesture.state == UIGestureRecognizerStateFailed) {
        
        if (_panning) {
            _panning = false;
            [self.collectionView performBatchUpdates:nil completion:nil];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return otherGestureRecognizer == self.collectionView.panGestureRecognizer;
}

@end
