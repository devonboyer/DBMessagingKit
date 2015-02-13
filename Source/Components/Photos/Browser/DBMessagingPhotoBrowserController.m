//
//  DBMessagingPhotoBrowserController.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2015-02-12.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingPhotoBrowserController.h"

#import "DBMessagingPhotoBrowserTransitionAnimator.h"

@interface DBMessagingPhotoBrowserPhotoCell: UICollectionViewCell

@property (strong, nonatomic) UIImageView *imageView;

+ (NSString *)cellReuseIdentifier;

@end

@implementation DBMessagingPhotoBrowserPhotoCell

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_imageView setClipsToBounds:YES];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _imageView.image = nil;
}

@end

@interface DBMessagingPhotoBrowserController () <UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerTransitioningDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (weak, nonatomic) IBOutlet UIToolbar *actionsToolbar;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation DBMessagingPhotoBrowserController

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
        
        _hidesBarsOnTap = YES;
    }
    return self;
}

- (instancetype)initWithSourceRect:(CGRect)sourceRect transitionPhoto:(UIImage *)transitionPhoto {
    self = [self init];
    if (self) {
        _sourceRect = sourceRect;
        _transitionPhoto = transitionPhoto;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[self class] nib] instantiateWithOwner:self options:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    if (presented == self) {
        return [[DBMessagingPhotoBrowserTransitionAnimator alloc] initWithSourceRect:_sourceRect
                                                                     destinationRect:CGRectZero
                                                                     transitionPhoto:_transitionPhoto];
    }
    
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    if (dismissed == self) {
        return [[DBMessagingPhotoBrowserTransitionAnimator alloc] initWithSourceRect:CGRectZero
                                                                     destinationRect:_sourceRect
                                                                     transitionPhoto:_transitionPhoto];
    }
    
    return nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_photoSource numberOfPhotosInPhotoBrowser:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DBMessagingPhotoBrowserPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DBMessagingPhotoBrowserPhotoCell cellReuseIdentifier] forIndexPath:indexPath];
    
    [_photoSource photoBrowser:self wantsPhotoForImageView:cell.imageView atIndexPath:indexPath];
    
    return cell;
}

@end
