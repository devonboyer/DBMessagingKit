//
//  DBMessagingCollectionViewBaseFlowLayout.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-19.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingCollectionViewBaseFlowLayout.h"
#import "DBMessagingKitConstants.h"
#import "DBMessagingCollectionView.h"
#import "DBMessagingCollectionViewLayoutAttributes.h"
#import "DBMessagingCollectionViewFlowLayoutInvalidationContext.h"
#import "NSAttributedString+Messaging.h"
#import "DBMessagingTimestampSupplementaryView.h"

NSString *const DBMessagingCollectionElementKindTimestamp = @"com.DBMessagingKit.DBMessagingCollectionElementKindTimestamp";

@interface DBMessagingCollectionViewBaseFlowLayout () {
    CGFloat _incomingMessageBubbleAvatarSpacing;
    CGFloat _outgoingMessageBubbleAvatarSpacing;
}

@property (strong, nonatomic) NSCache *messageBubbleCache;

// Temporary: There should be a cleaner way to handle this
@property (strong, nonatomic) NSCache *messageTopLabelCache;
@property (strong, nonatomic) NSCache *cellTopLabelCache;
@property (strong, nonatomic) NSCache *cellBottomLabelCache;

// Tiling and Springs
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) NSMutableSet *visibleIndexPaths;
@property (strong, nonatomic) NSMutableSet *visibleHeaderFooterIndexPaths;
@property (assign, nonatomic) CGFloat latestDelta;
@property (assign, nonatomic) UIInterfaceOrientation previousOrientation;

// Initial/Final layout attributes
@property (strong, nonatomic) NSMutableArray *insertedIndexPaths;

@end

@implementation DBMessagingCollectionViewBaseFlowLayout

+ (Class)invalidationContextClass
{
    return [DBMessagingCollectionViewFlowLayoutInvalidationContext class];
}

+ (Class)layoutAttributesClass
{
    return [DBMessagingCollectionViewLayoutAttributes class];
}

#pragma mark - Initialization

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

- (void)commonInit
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
    _messageBubbleCache.name = @"com.DBMessagingKit.messageBubbleCache";
    _messageBubbleCache.countLimit = 200.0;
    
    _messageTopLabelCache = [[NSCache alloc] init];
    _messageTopLabelCache.name = @"com.DBMessagingKit.messageTopLabelCache";
    _messageTopLabelCache.countLimit = _messageBubbleCache.countLimit;
    
    _cellTopLabelCache = [[NSCache alloc] init];
    _cellTopLabelCache.name = @"com.DBMessagingKit.cellTopLabelCache";
    _cellTopLabelCache.countLimit = _messageBubbleCache.countLimit;
    
    _cellBottomLabelCache = [[NSCache alloc] init];
    _cellBottomLabelCache.name = @"com.DBMessagingKit.cellBottomLabelCache";
    _cellBottomLabelCache.countLimit = _messageBubbleCache.countLimit;
    
    // Attributes that affect cells
    _messageBubbleTextViewTextContainerInsets = UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f);
    _messageBubbleFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    _springResistanceFactor = 1000.0;
    _messageBubbleLeftRightMargin = 70.0f;
    _incomingAvatarViewSize = CGSizeMake(34.0, 34.0);
    _outgoingAvatarViewSize = CGSizeMake(0.0, 0.0);
    _incomingImageSize = CGSizeMake(220.0, 240.0);
    _outgoingImageSize = CGSizeMake(220.0, 240.0);
    _incomingLocationMapSize = CGSizeMake(180.0, 100.0);
    _outgoingLocationMapSize = CGSizeMake(180.0, 100.0);
    _incomingMessageBubbleAvatarSpacing = 5.0;
    _outgoingMessageBubbleAvatarSpacing = 5.0;
    
    // Attributes that affect layout
    _cellTopLabelPadding = 20.0;
    _messageTopLabelPadding = 5.0;
    _cellBottomLabelPadding = 5.0;
    _inOutMessageBubbleInteritemSpacing = 10.0;
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
    
    if (self.dynamicsEnabled) {
        
        CGFloat padding = -100.0f;
        CGRect visibleRect = CGRectInset(self.collectionView.bounds, padding, padding);
        
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
    
    [attributesInRect enumerateObjectsUsingBlock:^(DBMessagingCollectionViewLayoutAttributes *layoutAttributes, NSUInteger idx, BOOL *stop) {
        
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
            [self _configureLayoutAttributes:layoutAttributes];
        }
    }];
    
    return attributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DBMessagingCollectionViewLayoutAttributes *layoutAttributes = (DBMessagingCollectionViewLayoutAttributes *)[super layoutAttributesForItemAtIndexPath:indexPath];
    
//    if (self.dynamicsEnabled) {
//        if ([_dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath]) {
//            layoutAttributes = (MessagingCollectionViewLayoutAttributes *)[_dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
//        }
//    }
    
    if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
        [self _configureLayoutAttributes:layoutAttributes];
    }
    
    return layoutAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    if (self.dynamicsEnabled) {
        UIScrollView *scrollView = self.collectionView;
        CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
        
        self.latestDelta = delta;
        
        CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
        
        [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
            [self adjustSpringBehavior:springBehaviour forTouchLocation:touchLocation];
            [self.dynamicAnimator updateItemUsingCurrentState:[springBehaviour.items firstObject]];
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

 
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            if(self.dynamicsEnabled &&
               [self.dynamicAnimator layoutAttributesForCellAtIndexPath:updateItem.indexPathAfterUpdate])
            {
                *stop = YES;
            }
            
            DBMessagingCollectionViewLayoutAttributes *attributes = [DBMessagingCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:updateItem.indexPathAfterUpdate];
            
            if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
                [self _configureLayoutAttributes:(DBMessagingCollectionViewLayoutAttributes *)attributes];
            }
            
            CGFloat collectionViewHeight = CGRectGetHeight(self.collectionView.bounds);
            attributes.frame = CGRectMake(0.0f,
                                          collectionViewHeight + CGRectGetHeight(attributes.frame),
                                          CGRectGetWidth(attributes.frame),
                                          CGRectGetHeight(attributes.frame));
            
            if (self.dynamicsEnabled) {
                UIAttachmentBehavior *springBehaviour = [self springBehaviorWithLayoutAttributesItem:attributes];
                [self.dynamicAnimator addBehavior:springBehaviour];
            }
        }
    }];
}

- (void)finalizeCollectionViewUpdates {
    [super finalizeCollectionViewUpdates];
    
    [_insertedIndexPaths removeAllObjects];
}

- (void)invalidateLayoutWithContext:(DBMessagingCollectionViewFlowLayoutInvalidationContext *)context
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

#pragma mark - Getters

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

#pragma mark - Setters

- (void)setDynamicsEnabled:(BOOL)dynamicsEnabled
{
    if (_dynamicsEnabled == dynamicsEnabled) {
        return;
    }
    
    _dynamicsEnabled = dynamicsEnabled;
    
    if (!dynamicsEnabled) {
        [_dynamicAnimator removeAllBehaviors];
        [_visibleIndexPaths removeAllObjects];
    }
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageBubbleFont:(UIFont *)messageBubbleFont
{
    if ([_messageBubbleFont isEqual:messageBubbleFont]) {
        return;
    }
    
    NSParameterAssert(messageBubbleFont != nil);
    _messageBubbleFont = messageBubbleFont;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageBubbleLeftRightMargin:(CGFloat)messageBubbleLeftRightMargin
{
    _messageBubbleLeftRightMargin = messageBubbleLeftRightMargin;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setIncomingAvatarViewSize:(CGSize)incomingAvatarViewSize
{
    _incomingAvatarViewSize = incomingAvatarViewSize;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setOutgoingAvatarViewSize:(CGSize)outgoingAvatarViewSize
{
    _outgoingAvatarViewSize = outgoingAvatarViewSize;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setIncomingImageSize:(CGSize)incomingImageSize
{
    _incomingImageSize = incomingImageSize;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setOutgoingImageSize:(CGSize)outgoingImageSize
{
    _outgoingImageSize = outgoingImageSize;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setIncomingLocationMapSize:(CGSize)incomingLocationMapSize {
    _incomingLocationMapSize = incomingLocationMapSize;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setOutgoingLocationMapSize:(CGSize)outgoingLocationMapSize {
    _outgoingLocationMapSize = outgoingLocationMapSize;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setIncomingMessageBubbleAvatarSpacing:(CGFloat)incomingMessageBubbleAvatarSpacing
{
    _incomingMessageBubbleAvatarSpacing = incomingMessageBubbleAvatarSpacing;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setOutgoingMessageBubbleAvatarSpacing:(CGFloat)outgoingMessageBubbleAvatarSpacing
{
    _outgoingMessageBubbleAvatarSpacing = outgoingMessageBubbleAvatarSpacing;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}
- (void)setInOutMessageBubbleInteritemSpacing:(CGFloat)inOutMessageBubbleInteritemSpacing
{
    _inOutMessageBubbleInteritemSpacing = inOutMessageBubbleInteritemSpacing;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setCellTopLabelPadding:(CGFloat)cellTopLabelPadding
{
    _cellTopLabelPadding = cellTopLabelPadding;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageTopLabelPadding:(CGFloat)messageTopLabelPadding
{
    _messageTopLabelPadding = messageTopLabelPadding;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setCellBottomLabelPadding:(CGFloat)cellBottomLabelPadding
{
    _cellBottomLabelPadding = cellBottomLabelPadding;
    [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
}

#pragma mark - Private

- (void)_resetLayout {
    [_messageBubbleCache removeAllObjects];
    [_cellTopLabelCache removeAllObjects];
    [_messageTopLabelCache removeAllObjects];
    [_cellBottomLabelCache removeAllObjects];
    [_cellTopLabelCache removeAllObjects];

    [self _resetDynamicAnimator];
}

- (void)_resetDynamicAnimator {
    [_dynamicAnimator removeAllBehaviors];
    [_visibleIndexPaths removeAllObjects];
}

- (void)_configureLayoutAttributes:(DBMessagingCollectionViewLayoutAttributes *)layoutAttributes
{
    NSIndexPath *indexPath = layoutAttributes.indexPath;
    
    CGSize messageBubbleSize = [self _messageBubbleSizeForItemAtIndexPath:indexPath];
    CGFloat remainingItemWidthForBubble = self.itemWidth - [self avatarSizeForIndexPath:indexPath].width - [self messageBubbleAvatarSpacingForIndexPath:indexPath];
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
    
    // Bottleneck: Recalculating these sizes every time the layout is invalidated, these are not cached in any way.
    // Since both the cells and layout height calculation require these values they need to be cached separately.
    // Possibly a cleaner way of handling this.
    
    layoutAttributes.cellTopLabelHeight = [self _cellTopLabelHeightForIndexPath:indexPath];
    
    layoutAttributes.messageBubbleTopLabelHeight = [self _messageTopLabelHeightForIndexPath:indexPath];
    
    layoutAttributes.cellBottomLabelHeight = [self _cellBottomLabelHeightForIndexPath:indexPath];
    
    layoutAttributes.messageBubbleFont = self.messageBubbleFont;
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
    
    CGSize avatarSize = [self avatarSizeForIndexPath:indexPath];
    
    CGFloat maximumTextWidth = self.itemWidth - avatarSize.width - self.messageBubbleLeftRightMargin - [self messageBubbleAvatarSpacingForIndexPath:indexPath];
    
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
            finalSize = [self _imageSizeForIndexPath:indexPath];
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
        case MIMETypeMovie: {
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

- (CGFloat)_messageBubbleTextContainerInsetsTotal
{
    UIEdgeInsets insets = self.messageBubbleTextViewTextContainerInsets;
    return insets.left + insets.right;
}

- (CGFloat)_cellTopLabelHeightForIndexPath:(NSIndexPath *)indexPath
{
    
    NSValue *cachedSize = [_cellTopLabelCache objectForKey:@(indexPath.hash)];
    if (cachedSize) {
        return [cachedSize CGSizeValue].height;
    }
    
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
    
    [_cellTopLabelCache setObject:[NSValue valueWithCGSize:CGSizeMake(0, cellTopLabelHeight)] forKey:@(indexPath.hash)];
    
    return cellTopLabelHeight;
}

- (CGFloat)_messageTopLabelHeightForIndexPath:(NSIndexPath *)indexPath
{
    
    NSValue *cachedSize = [_messageTopLabelCache objectForKey:@(indexPath.hash)];
    if (cachedSize) {
        return [cachedSize CGSizeValue].height;
    }
    
    CGFloat messageTopLabelHeight = 0;
    if ([self.collectionView.dataSource respondsToSelector:@selector(collectionView:messageTopLabelAttributedTextForItemAtIndexPath:)]) {
        NSAttributedString *messageTopLabelAttributedString = [self.collectionView.dataSource collectionView:self.collectionView messageTopLabelAttributedTextForItemAtIndexPath:indexPath];
        messageTopLabelHeight = [NSAttributedString boundingBoxForAttributedString:messageTopLabelAttributedString maxWidth:self.itemWidth].height;
        
        if (messageTopLabelHeight > 0) {
            messageTopLabelHeight += self.messageTopLabelPadding;
        }
    }
    
    [_messageTopLabelCache setObject:[NSValue valueWithCGSize:CGSizeMake(0, messageTopLabelHeight)] forKey:@(indexPath.hash)];
    
    return messageTopLabelHeight;
}

- (CGFloat)_cellBottomLabelHeightForIndexPath:(NSIndexPath *)indexPath
{
    
    NSValue *cachedSize = [_cellBottomLabelCache objectForKey:@(indexPath.hash)];
    if (cachedSize) {
        return [cachedSize CGSizeValue].height;
    }
    
    CGFloat cellBottomLabelHeight = 0;
    if ([self.collectionView.dataSource respondsToSelector:@selector(collectionView:cellBottomLabelAttributedTextForItemAtIndexPath:)]) {
        NSAttributedString *bottomLabelAttributedString = [self.collectionView.dataSource collectionView:self.collectionView cellBottomLabelAttributedTextForItemAtIndexPath:indexPath];
        cellBottomLabelHeight = [NSAttributedString boundingBoxForAttributedString:bottomLabelAttributedString maxWidth:self.itemWidth].height;
        
        if (cellBottomLabelHeight > 0) {
            cellBottomLabelHeight += self.cellBottomLabelPadding;
        }
    }
    
    [_cellBottomLabelCache setObject:[NSValue valueWithCGSize:CGSizeMake(0, cellBottomLabelHeight)] forKey:@(indexPath.hash)];
    
    return cellBottomLabelHeight;
}

#pragma mark - Public

- (CGSize)avatarSizeForIndexPath:(NSIndexPath *)indexPath
{
    if ([self isOutgoingMessageAtIndexPath:indexPath]) {
        return self.outgoingAvatarViewSize;
    }
    
    return self.incomingAvatarViewSize;
}

- (CGFloat)messageBubbleAvatarSpacingForIndexPath:(NSIndexPath *)indexPath
{
    if ([self isOutgoingMessageAtIndexPath:indexPath]) {
        return self.outgoingMessageBubbleAvatarSpacing;
    }
    
    return self.incomingMessageBubbleAvatarSpacing;
}

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
        [self invalidateLayoutWithContext:[DBMessagingCollectionViewFlowLayoutInvalidationContext context]];
    }

    _previousOrientation = [[UIApplication sharedApplication] statusBarOrientation];
}

#pragma mark - Spring Utilities

- (UIAttachmentBehavior *)springBehaviorWithLayoutAttributesItem:(UICollectionViewLayoutAttributes *)item
{
    UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
    springBehavior.length = 1.0f;
    springBehavior.damping = 1.0f;
    springBehavior.frequency = 1.0f;
    return springBehavior;
}

- (void)addNewlyVisibleBehaviorsFromVisibleItems:(NSArray *)visibleItems
{
    //  a "newly visible" item is in `visibleItems` but not in `self.visibleIndexPaths`
    NSIndexSet *indexSet = [visibleItems indexesOfObjectsPassingTest:^BOOL(UICollectionViewLayoutAttributes *item, NSUInteger index, BOOL *stop) {
        return ![self.visibleIndexPaths containsObject:item.indexPath];
    }];
    
    NSArray *newlyVisibleItems = [visibleItems objectsAtIndexes:indexSet];
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger index, BOOL *stop) {
        UIAttachmentBehavior *springBehaviour = [self springBehaviorWithLayoutAttributesItem:item];
        [self adjustSpringBehavior:springBehaviour forTouchLocation:touchLocation];
        [self.dynamicAnimator addBehavior:springBehaviour];
        [self.visibleIndexPaths addObject:item.indexPath];
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
    }];
}

- (void)adjustSpringBehavior:(UIAttachmentBehavior *)springBehavior forTouchLocation:(CGPoint)touchLocation
{
    UICollectionViewLayoutAttributes *item = [springBehavior.items firstObject];
    CGPoint center = item.center;
    
    //  if touch is not (0,0) -- adjust item center "in flight"
    if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
        CGFloat distanceFromTouch = fabsf(touchLocation.y - springBehavior.anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / self.springResistanceFactor;
        
        if (self.latestDelta < 0.0f) {
            center.y += MAX(self.latestDelta, self.latestDelta * scrollResistance);
        }
        else {
            center.y += MIN(self.latestDelta, self.latestDelta * scrollResistance);
        }
        item.center = center;
    }
}

@end
