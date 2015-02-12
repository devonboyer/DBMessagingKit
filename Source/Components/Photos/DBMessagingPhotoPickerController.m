//
//  DBMessagingPhotoPickerController.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2015-02-10.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingPhotoPickerController.h"

#import "DBMessagingPhotoPickerPresentationController.h"

#import "UIColor+Messaging.h"
#import "UIImage+Messaging.h"

#import <Photos/Photos.h>

@interface DBMessagingPhotoPickerOptionCell : UITableViewCell

+ (NSString *)cellReuseIdentifier;

@end

@implementation DBMessagingPhotoPickerOptionCell

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:20.0];
        self.textLabel.textColor = [UIColor iMessageBlueColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end

@interface DBMessagingPhotoPickerPhotoCell: UICollectionViewCell

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *selectionIndicatorButton;

+ (NSString *)cellReuseIdentifier;

- (void)setPercentVisible:(CGFloat)percent;

@end

@implementation DBMessagingPhotoPickerPhotoCell

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_imageView setClipsToBounds:YES];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:_imageView];
        
        _selectionIndicatorButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        [_selectionIndicatorButton setImage:[UIImage imageNamed:@"checkmark_icon"] forState:UIControlStateSelected];
        [_selectionIndicatorButton setImage:nil forState:UIControlStateNormal];
        [_selectionIndicatorButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
        [_selectionIndicatorButton setUserInteractionEnabled:NO];
        [_selectionIndicatorButton setClipsToBounds:YES];
        [_selectionIndicatorButton.layer setMasksToBounds:NO];
        [_selectionIndicatorButton.layer setCornerRadius:_selectionIndicatorButton.frame.size.height / 2.0];
        [_selectionIndicatorButton.layer setBorderWidth:1.0];
        [_selectionIndicatorButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        [_selectionIndicatorButton.layer setShadowColor:[UIColor blackColor].CGColor];
        [_selectionIndicatorButton.layer setShadowOpacity:0.4];
        [_selectionIndicatorButton.layer setShadowOffset:CGSizeMake(0, 0)];
        [_selectionIndicatorButton.layer setShadowRadius:3];
        [self.contentView addSubview:_selectionIndicatorButton];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _imageView.image = nil;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    _selectionIndicatorButton.selected = selected;
}

- (void)setPercentVisible:(CGFloat)percent {
    
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 4, 4, 4);
    CGFloat buttonWidth = _selectionIndicatorButton.frame.size.width;
    CGSize size = self.contentView.frame.size;
    CGPoint finalCenter = CGPointMake(size.width - buttonWidth / 2.0 - inset.right, size.height - buttonWidth / 2.0 - inset.bottom);
    CGPoint initialCenter = CGPointMake(inset.left + buttonWidth / 2.0, finalCenter.y);
    
    CGPoint newCenter = CGPointMake(MAX((size.width * percent) - buttonWidth / 2.0 - inset.right, initialCenter.x), finalCenter.y);
    _selectionIndicatorButton.center = newCenter;
}

@end

@interface DBMessagingPhotoPickerController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, PHPhotoLibraryChangeObserver>
{
    CGSize _imageManagerTargetSize;
    PHImageContentMode _imageManagerContentMode;
    PHImageRequestOptions *_imageManagerRequestOptions;
}

@property (weak, nonatomic) IBOutlet UITableView *optionsTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;

@property (strong, nonatomic) PHFetchOptions *fetchOptions;
@property (strong, nonatomic) PHFetchResult *collectionFetchResult;
@property (strong, nonatomic) PHFetchResult *collectionFetchResults;
@property (strong, nonatomic) PHCachingImageManager *imageManager;

@property (strong, nonatomic) NSMutableDictionary *selectedPhotosInfo;

@end

@implementation DBMessagingPhotoPickerController

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        
        _imageManager = [[PHCachingImageManager alloc] init];
        _imageManager.allowsCachingHighQualityImages = YES;
        
        CGFloat estimatedCellHeight = self.view.bounds.size.height - _optionsTableView.frame.size.height;
        CGSize estimatedCellSize = CGSizeMake(estimatedCellHeight * 1.2, estimatedCellHeight);
        
        _imageManagerContentMode = PHImageContentModeAspectFit;
        _imageManagerTargetSize = estimatedCellSize;
        _imageManagerRequestOptions = [[PHImageRequestOptions alloc] init];
        _imageManagerRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    }
    return self;
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[self class] nib] instantiateWithOwner:self options:nil];
    
    [_photosCollectionView setAllowsMultipleSelection:YES];
    _selectedPhotosInfo = [[NSMutableDictionary alloc] init];
    
    // 1. Try Recently Added (Smart Album)
    _collectionFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
    PHAssetCollection *collection = _collectionFetchResult.firstObject;
    
    self.collectionFetchResults = [PHAsset fetchAssetsInAssetCollection:collection options:self.fetchOptions];
    
    if (self.collectionFetchResults.count == 0) {
    
        // 2. Try Photo Stream (Album)
        _collectionFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
        collection = _collectionFetchResult.firstObject;
        
        self.collectionFetchResults = [PHAsset fetchAssetsInAssetCollection:collection options:self.fetchOptions];
    }
    
    if (self.collectionFetchResults.count == 0) {
   
        // 3. Use All Photos
        _collectionFetchResult = nil;
        
        self.collectionFetchResults = [PHAsset fetchAssetsWithOptions:self.fetchOptions];
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    [self resetImageManager];
    
    [_photosCollectionView registerClass:[DBMessagingPhotoPickerPhotoCell class] forCellWithReuseIdentifier:[DBMessagingPhotoPickerPhotoCell cellReuseIdentifier]];
    
    [_optionsTableView registerClass:[DBMessagingPhotoPickerOptionCell class] forCellReuseIdentifier:[DBMessagingPhotoPickerOptionCell cellReuseIdentifier]];
    
    [_optionsTableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"Header"];
}

#pragma mark - Getters

- (PHFetchOptions *)fetchOptions {
    
    if (!_fetchOptions) {
        _fetchOptions = [[PHFetchOptions alloc] init];
        _fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        _fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    }
    
    return _fetchOptions;
}

#pragma mark - UIViewControllerTransitioning

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    if (presented == self) {
        return [[DBMessagingPhotoPickerPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    }
    
    return nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionFetchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DBMessagingPhotoPickerPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DBMessagingPhotoPickerPhotoCell cellReuseIdentifier] forIndexPath:indexPath];
    
    PHAsset *asset = [self.collectionFetchResults objectAtIndex:indexPath.row];
    
    [self.imageManager requestImageForAsset:asset targetSize:_imageManagerTargetSize contentMode:_imageManagerContentMode options:_imageManagerRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        cell.imageView.image = result;
    }];
    
    
    // Adjust percent visible
    CGRect cellRect = [collectionView convertRect:cell.frame toView:self.view];
    CGFloat percentVisible = MAX((CGRectGetMaxX(collectionView.frame) - cellRect.origin.x) / cellRect.size.width, 0.0);
    
    if (percentVisible >= 1) {
        percentVisible = 1;
    }
    
    [cell setPercentVisible:percentVisible];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIEdgeInsets sectionInset = collectionViewLayout.sectionInset;
    
    PHAsset *asset = [self.collectionFetchResults objectAtIndex:indexPath.row];

    CGFloat itemHeight = collectionView.bounds.size.height - sectionInset.top - sectionInset.bottom;
    CGFloat ratio = itemHeight / (asset.pixelHeight / 2.0);
    CGFloat itemWidth = (asset.pixelWidth / 2.0) * ratio;
    
    return CGSizeMake(itemWidth, itemHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PHAsset *asset = [self.collectionFetchResults objectAtIndex:indexPath.row];
    
    [self.imageManager requestImageForAsset:asset targetSize:_imageManagerTargetSize contentMode:_imageManagerContentMode options:_imageManagerRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        
        _selectedPhotosInfo[indexPath] = result;
        
    }];
    
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    [_optionsTableView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [_selectedPhotosInfo removeObjectForKey:indexPath];
    
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

    [_optionsTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBMessagingPhotoPickerOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:[DBMessagingPhotoPickerOptionCell cellReuseIdentifier] forIndexPath:indexPath];
    
    BOOL actionState = [_photosCollectionView indexPathsForSelectedItems].count > 0;
    int photosCount = (int)[_photosCollectionView indexPathsForSelectedItems].count;
    
    switch (indexPath.row) {
        case DBMessagingPhotoPickerControllerOptionPhotoLibrary: {
            
            NSString *highlightedString = [NSString stringWithFormat:@"Send %d Photos", photosCount];
            if (photosCount == 1) {
                highlightedString = [highlightedString substringToIndex:highlightedString.length - 1];
            }
            
            cell.textLabel.text = (actionState) ? highlightedString : @"Photo Library";
            break;
        }
        case DBMessagingPhotoPickerControllerOptionTakePhoto:
            cell.textLabel.text = (actionState) ? @"Add Comment" : @"Take Photo";
            break;
        case DBMessagingPhotoPickerControllerOptionCancel:
            cell.textLabel.text = @"Cancel";
            break;
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.bounds.size.height / 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    [headerView.contentView setBackgroundColor:tableView.separatorColor];
    return headerView;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL actionState = [_photosCollectionView indexPathsForSelectedItems].count > 0;
    
    switch (indexPath.row) {
        case DBMessagingPhotoPickerControllerOptionPhotoLibrary:
            
            if (actionState) {
                
                if ([self.delegate respondsToSelector:@selector(photoPickerController:didFinishPickingPhotos:action:)]) {
                    [self.delegate photoPickerController:self didFinishPickingPhotos:_selectedPhotosInfo.allValues action:DBMessagingPhotoPickerControllerActionSend];
                }
                
            } else {
                [self dismissViewControllerAnimated:YES completion:^{
                    if ([self.delegate respondsToSelector:@selector(photoPickerController:didDismissWithOption:)]) {
                        [self.delegate photoPickerController:self didDismissWithOption:DBMessagingPhotoPickerControllerOptionPhotoLibrary];
                    }
                }];
            }
            break;
        case DBMessagingPhotoPickerControllerOptionTakePhoto:
            
            if (actionState) {
                
                if ([self.delegate respondsToSelector:@selector(photoPickerController:didFinishPickingPhotos:action:)]) {
                    [self.delegate photoPickerController:self didFinishPickingPhotos:_selectedPhotosInfo.allValues action:DBMessagingPhotoPickerControllerActionComment];
                }
                
            } else {
                [self dismissViewControllerAnimated:YES completion:^{
                    if ([self.delegate respondsToSelector:@selector(photoPickerController:didDismissWithOption:)]) {
                        [self.delegate photoPickerController:self didDismissWithOption:DBMessagingPhotoPickerControllerOptionTakePhoto];
                    }
                }];
            }
            break;
        case DBMessagingPhotoPickerControllerOptionCancel: {
            [self dismissViewControllerAnimated:YES completion:^{
                if ([self.delegate respondsToSelector:@selector(photoPickerController:didDismissWithOption:)]) {
                    [self.delegate photoPickerController:self didDismissWithOption:DBMessagingPhotoPickerControllerOptionCancel];
                }
            }];
            break;
        }
        default:
            break;
    }

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == _photosCollectionView) {
        
        for (DBMessagingPhotoPickerPhotoCell *cell in _photosCollectionView.visibleCells) {
            CGRect cellRect = [scrollView convertRect:cell.frame toView:self.view];
            CGFloat percentVisible = MAX((CGRectGetMaxX(scrollView.frame) - cellRect.origin.x) / cellRect.size.width, 0.0);
            
            if (percentVisible >= 1) {
                percentVisible = 1;
            }
            
            [cell setPercentVisible:percentVisible];
        }
    }
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!_collectionFetchResult) {
            _collectionFetchResults = [PHAsset fetchAssetsWithOptions:self.fetchOptions];
            
            [self resetImageManager];
            
            [_photosCollectionView reloadData];
        }
        
        PHFetchResult *updatedCollectionsFetchResult = nil;
        
        PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:_collectionFetchResult];
        if (changeDetails) {
            updatedCollectionsFetchResult = [changeDetails fetchResultAfterChanges];
        }
        
        if (updatedCollectionsFetchResult) {
            _collectionFetchResult = updatedCollectionsFetchResult;
            
            PHAssetCollection *collection = _collectionFetchResult.firstObject;
            
            _collectionFetchResults = [PHAsset fetchAssetsInAssetCollection:collection options:self.fetchOptions];
            
            [self resetImageManager];
            
            [_photosCollectionView reloadData];
        }
        
    });
}

#pragma mark - Utility

- (void)resetImageManager {
    
    [_imageManager stopCachingImagesForAllAssets];

    NSArray* assets = [self.collectionFetchResults objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionFetchResults.count)]];
    
    [_imageManager startCachingImagesForAssets:assets targetSize:_imageManagerTargetSize contentMode:_imageManagerContentMode options:_imageManagerRequestOptions];
}


@end


