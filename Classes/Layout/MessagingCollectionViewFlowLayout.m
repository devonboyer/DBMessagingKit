//
//  MessagingCollectionViewFlowLayout.m
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-09-19.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingCollectionViewFlowLayout.h"
#import "MessagingKitConstants.h"
#import "MessagingCollectionView.h"
#import "MessagingCollectionViewLayoutAttributes.h"
#import "MessagingCollectionViewFlowLayoutInvalidationContext.h"
#import "NSAttributedString+Messaging.h"
#import "MessagingTimestampSupplementaryView.h"

NSString *const MessagingCollectionElementKindTimestamp = @"MessagingCollectionElementKindTimestamp";
NSString *const MessagingCollectionElementKindLocationTimestamp = @"MessagingCollectionElementKindLocationTimestamp";

@interface MessagingCollectionViewFlowLayout ()
{
    CGFloat _incomingMessageBubbleAvatarSpacing;
    CGFloat _outgoingMessageBubbleAvatarSpacing;
}

@property (strong, nonatomic) NSCache *messageBubbleCache;

// Tiling and Springs
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) NSMutableSet *visibleIndexPaths;
@property (strong, nonatomic) NSMutableSet *visibleHeaderFooterIndexPaths;
@property (assign, nonatomic) CGFloat latestDelta;
@property (assign, nonatomic) UIInterfaceOrientation previousOrientation;

@property (strong, nonatomic) NSMutableArray *insertedIndexPaths;

// Caches for keeping current/previous attributes
@property (nonatomic, strong) NSMutableDictionary *currentSupplementaryAttributesByKind;
@property (nonatomic, strong) NSMutableDictionary *cachedSupplementaryAttributesByKind;

@end

@implementation MessagingCollectionViewFlowLayout

+ (Class)invalidationContextClass
{
    return [MessagingCollectionViewFlowLayoutInvalidationContext class];
}

+ (Class)layoutAttributesClass
{
    return [MessagingCollectionViewLayoutAttributes class];
}

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
    }
    return self;
}

- (void)setup
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidReceiveMemoryWarningNotification:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    _visibleIndexPaths = [[NSMutableSet alloc] init];
    _visibleHeaderFooterIndexPaths = [[NSMutableSet alloc] init];
    _insertedIndexPaths = [[NSMutableArray alloc] init];
    
    // Cache
    _messageBubbleCache = [[NSCache alloc] init];
    _messageBubbleCache.name = @"com.MessagingKit.messageBubbleCache";
    _messageBubbleCache.countLimit = 200.0;
    
    // Attributes that affect cells
    _messageBubbleTextViewTextContainerInsets = UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f);
    _messageBubbleFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    _springResistanceFactor = 1000.0;
    _messageBubbleLeftRightMargin = 50.0f;
    _incomingAvatarViewSize = CGSizeMake(34.0, 34.0);
    _outgoingAvatarViewSize = CGSizeMake(0.0, 0.0);
    _incomingImageSize = CGSizeMake(220.0, 240.0);
    _outgoingImageSize = CGSizeMake(220.0, 240.0);
    _incomingLocationMapSize = CGSizeMake(180.0, 100.0);
    _outgoingLocationMapSize = CGSizeMake(180.0, 100.0);
    _incomingMessageBubbleAvatarSpacing = 5.0;
    _outgoingMessageBubbleAvatarSpacing = 5.0;
    _inOutMessageBubbleInteritemSpacing = 10.0;
    
    // Attributes that affect layout
    _cellTopLabelPadding = 10.0;
    _messageTopLabelPadding = 5.0;
    _cellBottomLabelPadding = 5.0;
    _timestampSupplementaryViewPadding = 10.0;
    _dynamicsEnabled = NO;
    
    self.sectionInset = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self setMinimumLineSpacing:2.0];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_messageBubbleCache removeAllObjects];
    _messageBubbleCache = nil;
    
    [_dynamicAnimator removeAllBehaviors];
    _dynamicAnimator = nil;
    
    [_visibleIndexPaths removeAllObjects];
    _visibleIndexPaths = nil;
}

#pragma mark - Layout

- (void)prepareLayout
{
    [super prepareLayout];
    
    // Deep-copy attributes in current cache
    self.cachedSupplementaryAttributesByKind = [NSMutableDictionary dictionary];
    [self.currentSupplementaryAttributesByKind enumerateKeysAndObjectsUsingBlock:^(NSString *kind, NSMutableDictionary * attribByPath, BOOL *stop) {
        NSMutableDictionary * cachedAttribByPath = [[NSMutableDictionary alloc] initWithDictionary:attribByPath copyItems:YES];
        [self.cachedSupplementaryAttributesByKind setObject:cachedAttribByPath forKey:kind];
    }];
    
    if (self.dynamicsEnabled) {
        
        // pad rect to avoid flickering
        CGRect originalRect = (CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size};
        CGRect visibleRect = CGRectInset(originalRect, -100, -100);
        
        NSArray *visibleItems = [super layoutAttributesForElementsInRect:visibleRect];
        NSSet *visibleItemsIndexPaths = [NSSet setWithArray:[visibleItems valueForKey:NSStringFromSelector(@selector(indexPath))]];
        
        [self removeNoLongerVisibleBehaviorsFromVisibleItemsIndexPaths:visibleItemsIndexPaths];
        
        [self addNewlyVisibleBehaviorsFromVisibleItems:visibleItems];
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *superAttrributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *attributesInRect = [superAttrributes mutableCopy];
    
    if (self.dynamicsEnabled) {
        NSMutableArray *attributesInRectCopy = [attributesInRect mutableCopy];
        NSArray *dynamicAttributes = [self.dynamicAnimator itemsInRect:rect];
        
        // avoid duplicate attributes
        // use dynamic animator attribute item instead of regular item, if it exists
        for (UICollectionViewLayoutAttributes *eachItem in attributesInRect) {
            
            for (UICollectionViewLayoutAttributes *eachDynamicItem in dynamicAttributes) {
                if ([eachItem.indexPath isEqual:eachDynamicItem.indexPath]
                    && eachItem.representedElementCategory == eachDynamicItem.representedElementCategory) {
                    
                    [attributesInRectCopy removeObject:eachItem];
                    [attributesInRectCopy addObject:eachDynamicItem];
                    continue;
                }
            }
        }
        
        attributesInRect = attributesInRectCopy;
    }
    
    // Add supplementary views to specfic index paths
    for (UICollectionViewLayoutAttributes *attributes in superAttrributes)
    {
        [attributesInRect addObject:[self layoutAttributesForSupplementaryViewOfKind:MessagingCollectionElementKindTimestamp atIndexPath:attributes.indexPath]];
    }
    
    // Always cache all visible attributes so we can use them later when computing final/initial animated attributes
    [attributesInRect enumerateObjectsUsingBlock:^(MessagingCollectionViewLayoutAttributes *layoutAttributes, NSUInteger idx, BOOL *stop) {
        
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
            [self _configureLayoutAttributes:layoutAttributes];
        }
        else if (layoutAttributes.representedElementCategory == UICollectionElementCategorySupplementaryView) {
            NSMutableDictionary *supplementaryAttribuesByIndexPath = [self.currentSupplementaryAttributesByKind objectForKey:layoutAttributes.representedElementKind];
            if (supplementaryAttribuesByIndexPath == nil)
            {
                supplementaryAttribuesByIndexPath = [NSMutableDictionary dictionary];
                [self.currentSupplementaryAttributesByKind setObject:supplementaryAttribuesByIndexPath forKey:layoutAttributes.representedElementKind];
            }
            
            [supplementaryAttribuesByIndexPath setObject:layoutAttributes
                                                  forKey:layoutAttributes.indexPath];
        }
        
        if (_tappedIndexPath) {
            if ([_tappedIndexPath compare:layoutAttributes.indexPath] == NSOrderedAscending) {
                layoutAttributes.frame = [self _adjustedFrameForAttributes:layoutAttributes forElementKind:MessagingCollectionElementKindTimestamp];
            }
        }
    }];
    
    return attributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MessagingCollectionViewLayoutAttributes *layoutAttributes = (MessagingCollectionViewLayoutAttributes *)[super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (self.dynamicsEnabled) {
        if ([_dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath]) {
            layoutAttributes = (MessagingCollectionViewLayoutAttributes *)[_dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
        }
    }
    
    if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
        [self _configureLayoutAttributes:layoutAttributes];
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    MessagingCollectionViewLayoutAttributes *layoutAttributes = [MessagingCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    
    if (layoutAttributes) {
        
        //get the attributes for the related cell at this index path
        UICollectionViewLayoutAttributes *cellAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        
        if ([elementKind isEqualToString:MessagingCollectionElementKindTimestamp]) {
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

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    if (self.dynamicsEnabled) {
        UIScrollView *scrollView = self.collectionView;
        
        CGFloat delta;
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) delta = newBounds.origin.y - scrollView.bounds.origin.y;
        else delta = newBounds.origin.x - scrollView.bounds.origin.x;
        
        self.latestDelta = delta;
        
        CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
        
        [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
            if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                CGFloat distanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
                
                CGFloat scrollResistance;
                if (self.springResistanceFactor) scrollResistance = distanceFromTouch / self.springResistanceFactor;
                else scrollResistance = distanceFromTouch / self.springResistanceFactor;
                
                UICollectionViewLayoutAttributes *item = [springBehaviour.items firstObject];
                CGPoint center = item.center;
                if (delta < 0) center.y += MAX(delta, delta*scrollResistance);
                else center.y += MIN(delta, delta*scrollResistance);
                
                item.center = center;
                
                [self.dynamicAnimator updateItemUsingCurrentState:item];
            } else {
                CGFloat distanceFromTouch = fabsf(touchLocation.x - springBehaviour.anchorPoint.x);
                
                CGFloat scrollResistance;
                if (self.springResistanceFactor) scrollResistance = distanceFromTouch / self.springResistanceFactor;
                else scrollResistance = distanceFromTouch / self.springResistanceFactor;
                
                UICollectionViewLayoutAttributes *item = [springBehaviour.items firstObject];
                CGPoint center = item.center;
                if (delta < 0) center.x += MAX(delta, delta*scrollResistance);
                else center.x += MIN(delta, delta*scrollResistance);
                
                item.center = center;
                
                [self.dynamicAnimator updateItemUsingCurrentState:item];
            }
        }];
    }
    
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    
    return NO;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert)
        {
            
            [_insertedIndexPaths addObject:updateItem.indexPathAfterUpdate];
        }
    }];

    if (self.dynamicsEnabled) {
        [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
            if (updateItem.updateAction == UICollectionUpdateActionInsert) {
                if([self.dynamicAnimator layoutAttributesForCellAtIndexPath:updateItem.indexPathAfterUpdate])
                {
                    return;
                }
                
                MessagingCollectionViewLayoutAttributes *attributes = [MessagingCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:updateItem.indexPathAfterUpdate];
                
                CGSize size = self.collectionView.bounds.size;
                attributes.frame = CGRectMake(0.0f,
                                              size.height - size.width,
                                              size.width,
                                              size.width);
                
                if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
                    [self _configureLayoutAttributes:(MessagingCollectionViewLayoutAttributes *)attributes];
                }
                
                UIAttachmentBehavior *springBehaviour = [self springBehaviorWithLayoutAttributesItem:attributes];
                [self.dynamicAnimator addBehavior:springBehaviour];
            }
        }];
    }
}

- (void)finalizeCollectionViewUpdates {
    [super finalizeCollectionViewUpdates];
    
    [_insertedIndexPaths removeAllObjects];
}

- (void)invalidateLayoutWithContext:(MessagingCollectionViewFlowLayoutInvalidationContext *)context
{
    if (context.invalidateDataSourceCounts) {
        context.invalidateFlowLayoutAttributes = YES;
        context.invalidateFlowLayoutDelegateMetrics = YES;
    }
    
    if (context.invalidateFlowLayoutAttributes || context.invalidateFlowLayoutDelegateMetrics) {
        [self _resetDynamicAnimator];
    }
    
    if (context.emptyCache) {
        [self _resetLayout];
    }
    
    [super invalidateLayoutWithContext:context];
}

#pragma mark - Setters

- (void)setDynamicsEnabled:(BOOL)dynamicsEnabled
{
    _dynamicsEnabled = dynamicsEnabled;
    
    if (!dynamicsEnabled) {
        [_dynamicAnimator removeAllBehaviors];
        [_visibleIndexPaths removeAllObjects];
    }
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageBubbleFont:(UIFont *)messageBubbleFont
{
    NSParameterAssert(messageBubbleFont != nil);
    _messageBubbleFont = messageBubbleFont;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageBubbleLeftRightMargin:(CGFloat)messageBubbleLeftRightMargin
{
    _messageBubbleLeftRightMargin = messageBubbleLeftRightMargin;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setIncomingAvatarViewSize:(CGSize)incomingAvatarViewSize
{
    _incomingAvatarViewSize = incomingAvatarViewSize;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setOutgoingAvatarViewSize:(CGSize)outgoingAvatarViewSize
{
    _outgoingAvatarViewSize = outgoingAvatarViewSize;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setIncomingImageSize:(CGSize)incomingImageSize
{
    _incomingImageSize = incomingImageSize;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setOutgoingImageSize:(CGSize)outgoingImageSize
{
    _outgoingImageSize = outgoingImageSize;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setIncomingLocationMapSize:(CGSize)incomingLocationMapSize {
    _incomingLocationMapSize = incomingLocationMapSize;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setOutgoingLocationMapSize:(CGSize)outgoingLocationMapSize {
    _outgoingLocationMapSize = outgoingLocationMapSize;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setIncomingMessageBubbleAvatarSpacing:(CGFloat)incomingMessageBubbleAvatarSpacing
{
    _incomingMessageBubbleAvatarSpacing = incomingMessageBubbleAvatarSpacing;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setOutgoingMessageBubbleAvatarSpacing:(CGFloat)outgoingMessageBubbleAvatarSpacing
{
    _outgoingMessageBubbleAvatarSpacing = outgoingMessageBubbleAvatarSpacing;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}
- (void)setInOutMessageBubbleInteritemSpacing:(CGFloat)inOutMessageBubbleInteritemSpacing
{
    _inOutMessageBubbleInteritemSpacing = inOutMessageBubbleInteritemSpacing;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setCellTopLabelPadding:(CGFloat)cellTopLabelPadding
{
    _cellTopLabelPadding = cellTopLabelPadding;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageTopLabelPadding:(CGFloat)messageTopLabelPadding
{
    _messageTopLabelPadding = messageTopLabelPadding;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setCellBottomLabelPadding:(CGFloat)cellBottomLabelPadding
{
    _cellBottomLabelPadding = cellBottomLabelPadding;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setTimestampSupplementaryViewPadding:(CGFloat)timestampSupplementaryViewPadding
{
    _timestampSupplementaryViewPadding = timestampSupplementaryViewPadding;
    [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
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

- (UIDynamicAnimator *)dynamicAnimator
{
    if (!_dynamicAnimator) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    
    return _dynamicAnimator;
}

- (NSMutableSet *)visibleIndexPaths
{
    if (!_visibleIndexPaths) {
        _visibleIndexPaths = [NSMutableSet new];
    }
    return _visibleIndexPaths;
}

- (CGFloat)incomingMessageBubbleAvatarSpacing
{
    if (self.incomingAvatarViewSize.width == 0) {
        return 0.0f;
    }
    
    return _incomingMessageBubbleAvatarSpacing;
}

- (CGFloat)outgoingMessageBubbleAvatarSpacing
{
    if (self.outgoingAvatarViewSize.width == 0) {
        return 0.0f;
    }
    
    return _outgoingMessageBubbleAvatarSpacing;
}

#pragma mark - Private

- (void)_resetLayout {
    [_messageBubbleCache removeAllObjects];
    [self _resetDynamicAnimator];
}

- (void)_resetDynamicAnimator {
    [_dynamicAnimator removeAllBehaviors];
    [_visibleIndexPaths removeAllObjects];
}

- (void)_configureLayoutAttributes:(MessagingCollectionViewLayoutAttributes *)layoutAttributes
{
    NSIndexPath *indexPath = layoutAttributes.indexPath;
    
    CGSize messageBubbleSize = [self _messageBubbleSizeForItemAtIndexPath:indexPath];
    CGFloat remainingItemWidthForBubble = self.itemWidth - [self _avatarSizeForIndexPath:indexPath].width - [self _messageBubbleAvatarSpacingForIndexPath:indexPath];
    CGFloat textPadding = [self _messageBubbleTextContainerInsetsTotal];
    CGFloat messageBubblePadding = MAX(0, remainingItemWidthForBubble - messageBubbleSize.width - textPadding);
    
    layoutAttributes.messageBubbleLeftRightMargin = messageBubblePadding;
    
    layoutAttributes.incomingAvatarViewSize = self.incomingAvatarViewSize;
    
    layoutAttributes.outgoingAvatarViewSize = self.outgoingAvatarViewSize;
    
    layoutAttributes.incomingImageSize = self.incomingImageSize;
    
    layoutAttributes.outgoingImageSize = self.outgoingImageSize;
    
    layoutAttributes.incomingLocationMapSize = self.incomingLocationMapSize;
    
    layoutAttributes.outgoingLocationMapSize = self.outgoingLocationMapSize;
    
    layoutAttributes.incomingMessageBubbleAvatarSpacing = self.incomingMessageBubbleAvatarSpacing;
    
    layoutAttributes.outgoingMessageBubbleAvatarSpacing = self.outgoingMessageBubbleAvatarSpacing;
    
    layoutAttributes.messageBubbleTextViewTextContainerInsets = self.messageBubbleTextViewTextContainerInsets;
    
    layoutAttributes.cellTopLabelHeight = [self _cellTopLabelHeightForIndexPath:indexPath];
    
    layoutAttributes.messageBubbleTopLabelHeight = [self _messageTopLabelHeightForIndexPath:indexPath];
    
    layoutAttributes.cellBottomLabelHeight = [self _cellBottomLabelHeightForIndexPath:indexPath];
    
    layoutAttributes.messageBubbleFont = self.messageBubbleFont;
    
    layoutAttributes.inOutMessageBubbleInteritemSpacing = self.inOutMessageBubbleInteritemSpacing;
}

- (CGRect)_adjustedFrameForAttributes:(UICollectionViewLayoutAttributes *)attributes forElementKind:(NSString *)elementKind
{
    CGRect frame = attributes.frame;
    if ([elementKind isEqualToString:MessagingCollectionElementKindTimestamp]) {
        frame.origin.y += [self _timestampSupplementaryViewHeightForIndexPath:attributes.indexPath];
    }
    
    return frame;
}

- (CGSize)_messageBubbleSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSData *data = [self.collectionView.dataSource collectionView:self.collectionView dataForMessageAtIndexPath:indexPath];
    
    NSValue *cachedSize = [_messageBubbleCache objectForKey:@(indexPath.hash)];
    if (cachedSize) {
        return [cachedSize CGSizeValue];
    }

    MIMEType MIMEType = [self.collectionView.dataSource collectionView:self.collectionView MIMETypeForMessageAtIndexPath:indexPath];
    
    CGFloat cellTopLabelHeight = [self _cellTopLabelHeightForIndexPath:indexPath];
    
    CGFloat messageTopLabelHeight = [self _messageTopLabelHeightForIndexPath:indexPath];

    CGFloat cellBottomLabelHeight = [self _cellBottomLabelHeightForIndexPath:indexPath];
    
    CGSize avatarSize = [self _avatarSizeForIndexPath:indexPath];
    
    CGFloat maximumTextWidth = self.itemWidth - avatarSize.width - self.messageBubbleLeftRightMargin - [self _messageBubbleAvatarSpacingForIndexPath:indexPath];
    
    CGFloat textInsetsTotal = [self _messageBubbleTextContainerInsetsTotal];
    
    CGSize finalSize = CGSizeZero;
    switch (MIMEType) {
        case MIMETypeText: {
            NSString *messageText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            CGRect stringRect = [messageText boundingRectWithSize:CGSizeMake(maximumTextWidth - textInsetsTotal, CGFLOAT_MAX)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                attributes:@{NSFontAttributeName : self.messageBubbleFont}
                                                                   context:nil];
            finalSize = CGRectIntegral(stringRect).size;
            break;
        }
        case MIMETypeImage: {
            CGSize photoSize = [self _imageSizeForIndexPath:indexPath];
            CGSize imageSize = [[UIImage alloc] initWithData:data].size;
            finalSize.height = MIN(imageSize.height / (imageSize.width / photoSize.width), photoSize.height);
            break;
        }
        case MIMETypeLocation: {
            finalSize = [self _locationMapSizeForIndexPath:indexPath];
            break;
        }
        case MIMETypeGIF: {
            finalSize = [self _imageSizeForIndexPath:indexPath];
            break;
        }
        default:
            break;
    }
    
    // Account for the size of avatars, an avatar should never be larger than the size of the smallest message bubble.
    CGFloat minimumHeight = avatarSize.height;
    
    // HACK: Add extra 2 points of space because 'boundingRectWithSize:' slighly off, not sure why.
    CGFloat verticalInsets = self.messageBubbleTextViewTextContainerInsets.top + self.messageBubbleTextViewTextContainerInsets.bottom + 2.0;
    CGFloat messageBubbleHeight = finalSize.height + messageTopLabelHeight + cellTopLabelHeight + cellBottomLabelHeight  + verticalInsets;
    
    if (messageBubbleHeight < self.incomingAvatarViewSize.height) {
        self.incomingAvatarViewSize = CGSizeMake(messageBubbleHeight, messageBubbleHeight);
    }
    
    if (messageBubbleHeight < self.outgoingAvatarViewSize.height) {
        self.outgoingAvatarViewSize = CGSizeMake(messageBubbleHeight, messageBubbleHeight);
    }
    
    finalSize = CGSizeMake(finalSize.width, MAX(minimumHeight, messageBubbleHeight));
    
    [_messageBubbleCache setObject:[NSValue valueWithCGSize:finalSize] forKey:@(indexPath.hash)];
    
    return finalSize;
}

- (CGSize)_avatarSizeForIndexPath:(NSIndexPath *)indexPath
{
    if ([self isOutgoingMessageAtIndexPath:indexPath]) {
        return self.outgoingAvatarViewSize;
    }
    
    return self.incomingAvatarViewSize;
}

- (CGSize)_locationMapSizeForIndexPath:(NSIndexPath *)indexPath {
    if ([self isOutgoingMessageAtIndexPath:indexPath]) {
        return self.outgoingLocationMapSize;
    }
    
    return self.incomingLocationMapSize;
}

- (CGSize)_imageSizeForIndexPath:(NSIndexPath *)indexPath
{
    if ([self isOutgoingMessageAtIndexPath:indexPath]) {
        return self.outgoingImageSize;
    }
    
    return self.incomingImageSize;
}

- (CGFloat)_messageBubbleAvatarSpacingForIndexPath:(NSIndexPath *)indexPath
{
    if ([self isOutgoingMessageAtIndexPath:indexPath]) {
        return self.outgoingMessageBubbleAvatarSpacing;
    }
    
    return self.incomingMessageBubbleAvatarSpacing;
}

- (CGFloat)_messageBubbleTextContainerInsetsTotal
{
    UIEdgeInsets insets = self.messageBubbleTextViewTextContainerInsets;
    return insets.left + insets.right;
}

- (CGFloat)_cellTopLabelHeightForIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellTopLabelHeight = 0;
    if ([self.collectionView.dataSource respondsToSelector:@selector(collectionView:cellTopLabelAttributedTextForItemAtIndexPath:)]) {
        NSAttributedString *topLabelAttributedString = [self.collectionView.dataSource collectionView:self.collectionView cellTopLabelAttributedTextForItemAtIndexPath:indexPath];
        cellTopLabelHeight = [NSAttributedString boundingBoxForAttributedString:topLabelAttributedString maxWidth:self.itemWidth].height;
        
        if (cellTopLabelHeight > 0) {
            cellTopLabelHeight += self.cellTopLabelPadding;
        }
    }
    
    // Add padding to cellTopLabel to add extra padding between incoming and outgoing cells as oppose to messing
    // with cell frames in the layout
    if (indexPath.row > 0) {
        NSString *sentByUserID = [self.collectionView.dataSource collectionView:self.collectionView sentByUserIDForMessageAtIndexPath:indexPath];
        NSString *previousSentByUserID = [self.collectionView.dataSource collectionView:self.collectionView sentByUserIDForMessageAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row - 1 inSection:0]];
        
        if (![sentByUserID isEqualToString:previousSentByUserID]) {
            cellTopLabelHeight += self.inOutMessageBubbleInteritemSpacing;
        }
    }
    
    return cellTopLabelHeight;
}

- (CGFloat)_messageTopLabelHeightForIndexPath:(NSIndexPath *)indexPath
{
    CGFloat messageTopLabelHeight = 0;
    if ([self.collectionView.dataSource respondsToSelector:@selector(collectionView:messageTopLabelAttributedTextForItemAtIndexPath:)]) {
        NSAttributedString *messageTopLabelAttributedString = [self.collectionView.dataSource collectionView:self.collectionView messageTopLabelAttributedTextForItemAtIndexPath:indexPath];
        messageTopLabelHeight = [NSAttributedString boundingBoxForAttributedString:messageTopLabelAttributedString maxWidth:self.itemWidth].height;
        
        if (messageTopLabelHeight > 0) {
            messageTopLabelHeight += self.messageTopLabelPadding;
        }
    }
    
    return messageTopLabelHeight;
}

- (CGFloat)_cellBottomLabelHeightForIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellBottomLabelHeight = 0;
    if ([self.collectionView.dataSource respondsToSelector:@selector(collectionView:cellBottomLabelAttributedTextForItemAtIndexPath:)]) {
        NSAttributedString *bottomLabelAttributedString = [self.collectionView.dataSource collectionView:self.collectionView cellBottomLabelAttributedTextForItemAtIndexPath:indexPath];
        cellBottomLabelHeight = [NSAttributedString boundingBoxForAttributedString:bottomLabelAttributedString maxWidth:self.itemWidth].height;
        
        if (cellBottomLabelHeight > 0) {
            cellBottomLabelHeight += self.cellBottomLabelPadding;
        }
    }
    
    return cellBottomLabelHeight;
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



#pragma mark - Public

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemHeight = [self _messageBubbleSizeForItemAtIndexPath:indexPath].height;
    CGFloat itemWidth = self.itemWidth;
    return CGSizeMake(itemWidth, itemHeight);
}

- (BOOL)isOutgoingMessageAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sentByUserID = [self.collectionView.dataSource collectionView:self.collectionView sentByUserIDForMessageAtIndexPath:indexPath];
    return [sentByUserID isEqualToString:[self.collectionView.dataSource senderUserID]];
}

#pragma mark - Notifications

- (void)applicationDidReceiveMemoryWarningNotification:(NSNotification *)notification {
    [self _resetLayout];
}

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification
{
    if (_previousOrientation != [[UIApplication sharedApplication] statusBarOrientation]) {
        [self _resetLayout];
        [self invalidateLayoutWithContext:[MessagingCollectionViewFlowLayoutInvalidationContext context]];
    }

    _previousOrientation = [[UIApplication sharedApplication] statusBarOrientation];
}

#pragma mark - Spring Utilities

- (UIAttachmentBehavior *)springBehaviorWithLayoutAttributesItem:(UICollectionViewLayoutAttributes *)item
{
    UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
    springBehavior.length = 1.0f;
    springBehavior.damping = 1.0f;
    springBehavior.frequency = 2.5f;
    return springBehavior;
}

- (void)addNewlyVisibleBehaviorsFromVisibleItems:(NSArray *)visibleItems
{
    //  a "newly visible" item is in `visibleItems` but not in `self.visibleIndexPaths`
    NSIndexSet *indexSet = [visibleItems indexesOfObjectsPassingTest:^BOOL(UICollectionViewLayoutAttributes *item, NSUInteger index, BOOL *stop) {
        return (item.representedElementCategory == UICollectionElementCategoryCell ?
                [self.visibleIndexPaths containsObject:item.indexPath] : [self.visibleHeaderFooterIndexPaths containsObject:item.indexPath]) == NO;
    }];
    
    NSArray *newlyVisibleItems = [visibleItems objectsAtIndexes:indexSet];
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger index, BOOL *stop) {
        UIAttachmentBehavior *springBehaviour = [self springBehaviorWithLayoutAttributesItem:item];
        [self adjustSpringBehavior:springBehaviour forTouchLocation:touchLocation];
        [self.dynamicAnimator addBehavior:springBehaviour];
        if(item.representedElementCategory == UICollectionElementCategoryCell) {
            [self.visibleIndexPaths addObject:item.indexPath];
        }
        else {
            [self.visibleHeaderFooterIndexPaths addObject:item.indexPath];
        }
    }];
}

- (void)removeNoLongerVisibleBehaviorsFromVisibleItemsIndexPaths:(NSSet *)visibleItemsIndexPaths
{
    NSArray *behaviors = self.dynamicAnimator.behaviors;
    
    NSIndexSet *indexSet = [behaviors indexesOfObjectsPassingTest:^BOOL(UIAttachmentBehavior *springBehaviour, NSUInteger index, BOOL *stop) {
        UICollectionViewLayoutAttributes *layoutAttributes = [springBehaviour.items firstObject];
        return ![visibleItemsIndexPaths containsObject:layoutAttributes.indexPath];
    }];
    
    NSArray *behaviorsToRemove = [self.dynamicAnimator.behaviors objectsAtIndexes:indexSet];
    
    [behaviorsToRemove enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger index, BOOL *stop) {
        UICollectionViewLayoutAttributes *layoutAttributes = [springBehaviour.items firstObject];
        [self.dynamicAnimator removeBehavior:springBehaviour];
        [self.visibleIndexPaths removeObject:layoutAttributes.indexPath];
        [self.visibleHeaderFooterIndexPaths removeObject:layoutAttributes.indexPath];
    }];
}

- (void)adjustSpringBehavior:(UIAttachmentBehavior *)springBehavior forTouchLocation:(CGPoint)touchLocation
{
    UICollectionViewLayoutAttributes *item = [springBehavior.items firstObject];
    CGPoint center = item.center;
    
    // If our touchLocation is not (0,0), we'll need to adjust our item's center "in flight"
    if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            CGFloat distanceFromTouch = fabsf(touchLocation.y - springBehavior.anchorPoint.y);
            
            CGFloat scrollResistance;
            if (self.springResistanceFactor) scrollResistance = distanceFromTouch / self.springResistanceFactor;
            else scrollResistance = distanceFromTouch / self.springResistanceFactor;
            
            if (self.latestDelta < 0) center.y += MAX(self.latestDelta, self.latestDelta*scrollResistance);
            else center.y += MIN(self.latestDelta, self.latestDelta*scrollResistance);
            
            item.center = center;
            
        } else {
            CGFloat distanceFromTouch = fabsf(touchLocation.x - springBehavior.anchorPoint.x);
            
            CGFloat scrollResistance;
            if (self.springResistanceFactor) scrollResistance = distanceFromTouch / self.springResistanceFactor;
            else scrollResistance = distanceFromTouch / self.springResistanceFactor;
            
            if (self.latestDelta < 0) center.x += MAX(self.latestDelta, self.latestDelta*scrollResistance);
            else center.x += MIN(self.latestDelta, self.latestDelta*scrollResistance);
            
            item.center = center;
        }
    }
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
   
    MessagingCollectionViewLayoutAttributes *layoutAttributes;
    
    if ([_insertedIndexPaths containsObject:itemIndexPath])
    {
        layoutAttributes = (MessagingCollectionViewLayoutAttributes *)[self layoutAttributesForItemAtIndexPath:itemIndexPath];
        
        layoutAttributes.alpha = 0.0f;
        layoutAttributes.transform3D = CATransform3DMakeTranslation(0, CGRectGetHeight(layoutAttributes.frame), 0);
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    
    UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath];
    
    CGAffineTransform translation = CGAffineTransformMakeTranslation(0, 0);
    CGFloat translationInset = self.messageBubbleTextViewTextContainerInsets.left + self.messageBubbleTextViewTextContainerInsets.right+ [self _messageBubbleAvatarSpacingForIndexPath:elementIndexPath] + [self _avatarSizeForIndexPath:elementIndexPath].width + 50.0;
    
    if ([self isOutgoingMessageAtIndexPath:elementIndexPath]) {
        translation = CGAffineTransformMakeTranslation((layoutAttributes.frame.size.width - translationInset), -layoutAttributes.frame.size.height);
    }
    else {
        translation = CGAffineTransformMakeTranslation(-(layoutAttributes.frame.size.width - translationInset), -layoutAttributes.frame.size.height);
    }
    
    layoutAttributes.transform = CGAffineTransformScale(translation, 0.0, 0.0);
    
    return layoutAttributes;
}

@end
