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

#import "DBMessagingPhotoPickerPresentationControler.h"
#import "UIColor+Messaging.h"
#import "UIScrollView+Messaging.h"

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

+ (NSString *)cellReuseIdentifier;

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
    }
    return self;
}

@end

@interface DBMessagingPhotoPickerController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, PHPhotoLibraryChangeObserver>
{
    BOOL _highlighted;
}

@property (weak, nonatomic) IBOutlet UITableView *optionsTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *snapshotImageView;

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
    }
    return self;
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [self.imageManager stopCachingImagesForAllAssets];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[self class] nib] instantiateWithOwner:self options:nil];
    
    [_photosCollectionView setAllowsMultipleSelection:YES];
    _selectedPhotosInfo = [[NSMutableDictionary alloc] init];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    
    // Recently Added (Smart Album)
    _collectionFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
    PHAssetCollection *collection = _collectionFetchResult.firstObject;
    
    self.collectionFetchResults = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    
    if (self.collectionFetchResults.count == 0) {
    
        // Photo Stream (Album)
        _collectionFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
        collection = _collectionFetchResult.firstObject;
        
        self.collectionFetchResults = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    }
    
    if (self.collectionFetchResults.count == 0) {
   
        // All Photos
        _collectionFetchResult = nil;
        
        self.collectionFetchResults = [PHAsset fetchAssetsWithOptions:options];
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    [_photosCollectionView registerClass:[DBMessagingPhotoPickerPhotoCell class] forCellWithReuseIdentifier:[DBMessagingPhotoPickerPhotoCell cellReuseIdentifier]];
    
    [_optionsTableView registerClass:[DBMessagingPhotoPickerOptionCell class] forCellReuseIdentifier:[DBMessagingPhotoPickerOptionCell cellReuseIdentifier]];
}

#pragma mark - Getters

- (PHCachingImageManager *)imageManager {
    
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
        
        NSArray* assets = [self.collectionFetchResults objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionFetchResults.count)]];
        [_imageManager startCachingImagesForAssets:assets targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:nil];
    }
    
    return _imageManager;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionFetchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DBMessagingPhotoPickerPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DBMessagingPhotoPickerPhotoCell cellReuseIdentifier] forIndexPath:indexPath];
    
    PHAsset *asset = [self.collectionFetchResults objectAtIndex:indexPath.row];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    [self.imageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        cell.imageView.image = result;
    }];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!_highlighted) {
        
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        
        UIImage *snapshot = [collectionView snapshotVisibleRect];
        _snapshotImageView.image = snapshot;
        
        if (_selectedPhotosInfo.count == 0) {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect presentingViewBounds = self.presentingViewController.view.bounds;
                
                CGFloat scaleFactor = (presentingViewBounds.size.height * 0.7 - _optionsTableView.frame.size.height) / collectionView.frame.size.height;
                CGAffineTransform translation = CGAffineTransformMakeTranslation(cell.frame.size.width * scaleFactor, 0.0);
                _snapshotImageView.transform = CGAffineTransformScale(translation, scaleFactor, 1.0);
                
                CGRect frame = self.view.frame;
                frame.size.height = presentingViewBounds.size.height * 0.7;
                frame.origin.y = presentingViewBounds.size.height - frame.size.height;
                self.view.frame = frame;
                
                [self.view layoutIfNeeded];
                [collectionView.collectionViewLayout invalidateLayout];
                
            } completion:^(BOOL finished) {
                if (finished) {
                    [_snapshotImageView removeFromSuperview];
                    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
                    _highlighted = YES;
                }
            }];
        }
    }
    
    return YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIEdgeInsets sectionInset = collectionViewLayout.sectionInset;
    
    return CGSizeMake(collectionView.bounds.size.height * 0.54,
                      collectionView.bounds.size.height - sectionInset.top - sectionInset.bottom);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PHAsset *asset = [self.collectionFetchResults objectAtIndex:indexPath.row];
    
    [self.imageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        
        _selectedPhotosInfo[indexPath] = result;
        
    }];
    
    if (_highlighted) {
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
    
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
                if ([self.delegate respondsToSelector:@selector(photoPickerController:didDismissWithOption:)]) {
                    [self.delegate photoPickerController:self didDismissWithOption:DBMessagingPhotoPickerControllerOptionPhotoLibrary];
                }
            }
            break;
        case DBMessagingPhotoPickerControllerOptionTakePhoto:
            
            if (actionState) {
                
                if ([self.delegate respondsToSelector:@selector(photoPickerController:didFinishPickingPhotos:action:)]) {
                    [self.delegate photoPickerController:self didFinishPickingPhotos:_selectedPhotosInfo.allValues action:DBMessagingPhotoPickerControllerActionComment];
                }
                
            } else {
                if ([self.delegate respondsToSelector:@selector(photoPickerController:didDismissWithOption:)]) {
                    [self.delegate photoPickerController:self didDismissWithOption:DBMessagingPhotoPickerControllerOptionTakePhoto];
                }
            }
            break;
        case DBMessagingPhotoPickerControllerOptionCancel:
            if ([self.delegate respondsToSelector:@selector(photoPickerController:didDismissWithOption:)]) {
                [self.delegate photoPickerController:self didDismissWithOption:DBMessagingPhotoPickerControllerOptionCancel];
            }
            break;
        default:
            break;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        
        if (!_collectionFetchResult) {
            _collectionFetchResults = [PHAsset fetchAssetsWithOptions:options];
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
            
            _collectionFetchResults = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            [_photosCollectionView reloadData];
        }
        
    });
}

#pragma mark - UIViewControllerTransitioning

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    if (presented == self) {
        return [[DBMessagingPhotoPickerPresentationControler alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    }
    
    return nil;
}

@end


