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
            
            if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
                if ([self isOutgoingMessageAtIndexPath:layoutAttributes.indexPath]) {
                    if (abs(change) < maxChange) {
                        frame.origin.x = MIN(-change, self.sectionInset.left);
                    } else {
                        frame.origin.x = MIN(-maxChange, self.sectionInset.left);
                    }
                }
            } else if (layoutAttributes.representedElementCategory == UICollectionElementCategorySupplementaryView) {
                if (layoutAttributes.representedElementKind == DBMessagingCollectionElementKindTimestamp) {
                    CGFloat max = self.collectionView.frame.size.width;
                    CGFloat relativeWidth = self.collectionView.frame.size.width - self.sectionInset.right;
                    if (abs(change) < maxChange) {
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
        
        if (velocity.x < 0 && cvVelocity.y == 0) {
            _startLocation = [panGesture locationInView:self.collectionView];
            _panning = true;
        }
    }
    
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        _panLocation = [panGesture locationInView:self.collectionView];
        [self invalidateLayout];
    }
    
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        _panning = false;
        [self.collectionView performBatchUpdates:nil completion:nil];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return otherGestureRecognizer == self.collectionView.panGestureRecognizer;
}

@end
