//
//  DBMessagingCollectionViewHiddenTimestampFlowLayout.m
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

#import "DBMessagingCollectionViewHiddenTimestampFlowLayout.h"

#import "DBMessagingCollectionViewLayoutAttributes.h"
#import "DBMessagingCollectionViewFlowLayoutInvalidationContext.h"
#import "DBMessagingCollectionView.h"
#import "NSAttributedString+Messaging.h"

@interface DBMessagingCollectionViewHiddenTimestampFlowLayout ()

@end

@implementation DBMessagingCollectionViewHiddenTimestampFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    _timestampSupplementaryViewPadding = 10.0f;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *superAttrributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *attributesInRect = [superAttrributes mutableCopy];
    
    // Add supplementary views to specfic index paths
    for (UICollectionViewLayoutAttributes *attributes in superAttrributes)
    {
        [attributesInRect addObject:[self layoutAttributesForSupplementaryViewOfKind:DBMessagingCollectionElementKindTimestamp atIndexPath:attributes.indexPath]];
    }
    
    [attributesInRect enumerateObjectsUsingBlock:^(DBMessagingCollectionViewLayoutAttributes *layoutAttributes, NSUInteger idx, BOOL *stop) {
        
        if (_tappedIndexPath) {
            if ([_tappedIndexPath compare:layoutAttributes.indexPath] == NSOrderedAscending) {
                layoutAttributes.frame = [self _adjustedFrameForAttributes:layoutAttributes forElementKind:DBMessagingCollectionElementKindTimestamp];
            }
        }
    }];

    
    return attributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    DBMessagingCollectionViewLayoutAttributes *layoutAttributes = [DBMessagingCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    
    if (layoutAttributes) {
        
        //get the attributes for the related cell at this index path
        UICollectionViewLayoutAttributes *cellAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        
        if ([elementKind isEqualToString:DBMessagingCollectionElementKindTimestamp]) {
            layoutAttributes.incomingAvatarViewSize = self.incomingAvatarViewSize;
            layoutAttributes.outgoingAvatarViewSize = self.outgoingAvatarViewSize;
            layoutAttributes.messageBubbleTextViewTextContainerInsets = self.messageBubbleTextViewTextContainerInsets;
            
            if ([indexPath isEqual:_tappedIndexPath]) {
                layoutAttributes.frame = CGRectMake(CGRectGetMinX(cellAttributes.frame), CGRectGetMaxY(cellAttributes.frame), self.itemWidth, [self _timestampSupplementaryViewHeightForIndexPath:indexPath]);
            }
            else {
                layoutAttributes.frame = CGRectZero;
            }
        }
    }
    
    return layoutAttributes;
}

#pragma mark - Setters

- (void)setTimestampSupplementaryViewPadding:(CGFloat)timestampSupplementaryViewPadding
{
    _timestampSupplementaryViewPadding = timestampSupplementaryViewPadding;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setTappedIndexPath:(NSIndexPath *)tappedIndexPath
{
    _tappedIndexPath = ([_tappedIndexPath isEqual:tappedIndexPath]) ? nil : tappedIndexPath;
    
    // Highlight the selected item
    [self.collectionView selectItemAtIndexPath:_tappedIndexPath
                                      animated:YES
                                scrollPosition:UICollectionViewScrollPositionNone];
    
    // Animate the timestamp to become visible
    [self.collectionView performBatchUpdates:^{
        
        if (_tappedIndexPath) {
            // Scroll to make the timestamp visible
            CGRect visibleRect = [self.collectionView cellForItemAtIndexPath:_tappedIndexPath].frame;
            visibleRect.origin.y += [self _timestampSupplementaryViewHeightForIndexPath:_tappedIndexPath];
            [self.collectionView scrollRectToVisible:visibleRect animated:true];
        }
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self invalidateLayout];
        }
    }];
}

#pragma mark - Getters

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = [super collectionViewContentSize];
    
    if (self.tappedIndexPath) {
        contentSize.height += [self _timestampSupplementaryViewHeightForIndexPath:self.tappedIndexPath];
    }
    
    return contentSize;
}

- (CGFloat)itemWidth
{
    return CGRectGetWidth(self.collectionView.bounds) - self.sectionInset.left - self.sectionInset.right;
}

#pragma mark - Utility

- (CGRect)_adjustedFrameForAttributes:(UICollectionViewLayoutAttributes *)attributes forElementKind:(NSString *)elementKind
{
    CGRect frame = attributes.frame;
    if ([elementKind isEqualToString:DBMessagingCollectionElementKindTimestamp]) {
        frame.origin.y += [self _timestampSupplementaryViewHeightForIndexPath:attributes.indexPath];
    }
    
    return frame;
}

- (CGFloat)_timestampSupplementaryViewHeightForIndexPath:(NSIndexPath *)indexPath
{
    CGFloat timestampSupplementaryViewHeight = 0;
    if ([self.collectionView.dataSource respondsToSelector:@selector(collectionView:cellBottomLabelAttributedTextForItemAtIndexPath:)]) {
        NSAttributedString *timestampAttributedString = [self.collectionView.dataSource collectionView:self.collectionView timestampAttributedTextForSupplementaryViewAtIndexPath:indexPath];
        timestampSupplementaryViewHeight = [NSAttributedString boundingBoxForAttributedString:timestampAttributedString maxWidth:self.itemWidth].height;
        
        if (timestampSupplementaryViewHeight > 0) {
            timestampSupplementaryViewHeight += self.timestampSupplementaryViewPadding;
        }
    }
    
    return timestampSupplementaryViewHeight;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    
    UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath];
    
    if ([elementKind isEqualToString:DBMessagingCollectionElementKindTimestamp]) {
        CGAffineTransform translation = CGAffineTransformMakeTranslation(0, 0);
        CGFloat translationInset = 80.0; //[self _messageBubbleAvatarSpacingForIndexPath:elementIndexPath] + [self _avatarSizeForIndexPath:elementIndexPath].width + 50.0;
        
        if ([self isOutgoingMessageAtIndexPath:elementIndexPath]) {
            translation = CGAffineTransformMakeTranslation((layoutAttributes.frame.size.width - translationInset), -layoutAttributes.frame.size.height);
        }
        else {
            translation = CGAffineTransformMakeTranslation(-(layoutAttributes.frame.size.width - translationInset), -layoutAttributes.frame.size.height);
        }
        
        layoutAttributes.transform = CGAffineTransformScale(translation, 0.0, 0.0);
    }
    
    return layoutAttributes;
}

@end
