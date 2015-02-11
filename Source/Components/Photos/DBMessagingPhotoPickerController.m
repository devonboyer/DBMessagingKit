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
#import "UIView+Messaging.h"

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

@interface DBMessagingPhotoPickerController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) IBOutlet UITableView *optionsTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *snapshotImageView;

@property (strong, nonatomic) PHFetchResult *collectionsFetchResults;
@property (strong, nonatomic) PHCachingImageManager *manager;

@end

@implementation DBMessagingPhotoPickerController

typedef NS_ENUM(NSInteger, DBMessagingPhotoPickerControllerOption) {
    DBMessagingPhotoPickerControllerOptionPhotoLibrary,
    DBMessagingPhotoPickerControllerOptionTakePhoto,
    DBMessagingPhotoPickerControllerOptionCancel
};

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
        
        _manager = [[PHCachingImageManager alloc] init];
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
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    
    self.collectionsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    
    // [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    [_photosCollectionView registerClass:[DBMessagingPhotoPickerPhotoCell class] forCellWithReuseIdentifier:[DBMessagingPhotoPickerPhotoCell cellReuseIdentifier]];
    
    [_optionsTableView registerClass:[DBMessagingPhotoPickerOptionCell class] forCellReuseIdentifier:[DBMessagingPhotoPickerOptionCell cellReuseIdentifier]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionsFetchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DBMessagingPhotoPickerPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DBMessagingPhotoPickerPhotoCell cellReuseIdentifier] forIndexPath:indexPath];
    
    PHAsset *asset = [self.collectionsFetchResults objectAtIndex:indexPath.row];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    [_manager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        cell.imageView.image = result;
    }];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[collectionView indexPathsForSelectedItems] containsObject:indexPath]) {
        return YES;
    }
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    UIImage *snapshot = [collectionView snapshotRect:collectionView.bounds];
    _snapshotImageView.image = snapshot;
    
    if (_selectedPhotos.count == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect screenBounds = [[UIScreen mainScreen] bounds];
            
            CGFloat scaleFactor = (screenBounds.size.height * 0.7 - 150.0) / collectionView.frame.size.height;
            CGAffineTransform translation = CGAffineTransformMakeTranslation(cell.frame.size.width * scaleFactor, 0.0);
            _snapshotImageView.transform = CGAffineTransformScale(translation, scaleFactor, 1.0);
            
            CGRect frame = self.view.frame;
            frame.size.height = screenBounds.size.height * 0.7;
            frame.origin.y = screenBounds.size.height - frame.size.height;
            self.view.frame = frame;
            
            [self.view layoutIfNeeded];
            [collectionView.collectionViewLayout invalidateLayout];
            
        } completion:^(BOOL finished) {
            if (finished) {
                
                [_snapshotImageView removeFromSuperview];
                
                [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            }
        }];
    }
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    PHAsset *asset = [self.collectionsFetchResults objectAtIndex:indexPath.row];
    
    [_manager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        
        NSMutableArray *mutableSelectedPhotos = _selectedPhotos.mutableCopy;
        [mutableSelectedPhotos addObject:result];
        _selectedPhotos = mutableSelectedPhotos;
    }];
    
    return YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIEdgeInsets sectionInset = collectionViewLayout.sectionInset;
    
    return CGSizeMake(collectionView.bounds.size.height * 0.54,
                      collectionView.bounds.size.height - sectionInset.top - sectionInset.bottom);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  //  [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBMessagingPhotoPickerOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:[DBMessagingPhotoPickerOptionCell cellReuseIdentifier] forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case DBMessagingPhotoPickerControllerOptionPhotoLibrary:
            cell.textLabel.text = @"Photo Library";
            break;
        case DBMessagingPhotoPickerControllerOptionTakePhoto:
            cell.textLabel.text = @"Take Photo";
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
    
    UIImagePickerControllerSourceType sourceType;
    
    switch (indexPath.row) {
        case DBMessagingPhotoPickerControllerOptionPhotoLibrary:
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case DBMessagingPhotoPickerControllerOptionTakePhoto:
            sourceType = UIImagePickerControllerSourceTypeCamera;

#if TARGET_IPHONE_SIMULATOR
            
            NSLog(@"Error: The camera is unavailable on the simulator.");
            
            if ([self.delegate respondsToSelector:@selector(photoPickerControllerDidCancel:)]) {
                [self.delegate photoPickerControllerDidCancel:self];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
#endif
            break;
        case DBMessagingPhotoPickerControllerOptionCancel:
            if ([self.delegate respondsToSelector:@selector(photoPickerControllerDidCancel:)]) {
                [self.delegate photoPickerControllerDidCancel:self];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{

        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = sourceType;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:imagePickerController animated:YES completion:nil];
    }];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *updatedCollectionsFetchResults = nil;
        
        for (PHFetchResult *collectionsFetchResult in self.collectionsFetchResults) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            if (changeDetails) {
                if (!updatedCollectionsFetchResults) {
                    updatedCollectionsFetchResults = [self.collectionsFetchResults mutableCopy];
                }
                [updatedCollectionsFetchResults replaceObjectAtIndex:[self.collectionsFetchResults indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
            }
        }
        
        if (updatedCollectionsFetchResults) {
            self.collectionsFetchResults = updatedCollectionsFetchResults;
            [_photosCollectionView reloadData];
        }
        
    });
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
 
    if ([self.delegate respondsToSelector:@selector(photoPickerController:didFinishPickingPhotos:)]) {
        [self.delegate photoPickerController:self didFinishPickingPhotos:@[info[UIImagePickerControllerOriginalImage]]];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioning

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    if (presented == self) {
        return [[DBMessagingPhotoPickerPresentationControler alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    }
    
    return nil;
}

@end


