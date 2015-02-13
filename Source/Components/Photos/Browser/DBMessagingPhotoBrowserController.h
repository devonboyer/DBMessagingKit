//
//  DBMessagingPhotoBrowserController.h
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

#import <UIKit/UIKit.h>

@class DBMessagingPhotoBrowserController;

@protocol DBMessagingPhotoBrowserPhotoSource <NSObject>

@required

- (NSInteger)numberOfPhotosInPhotoBrowser:(DBMessagingPhotoBrowserController *)photoBrowser;

- (UICollectionViewCell *)photoBrowser:(DBMessagingPhotoBrowserController *)photoBrowser wantsPhotoForImageView:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath;

@end

NS_CLASS_AVAILABLE_IOS(7_0) @interface DBMessagingPhotoBrowserController : UIViewController

@property (weak, nonatomic) id<DBMessagingPhotoBrowserPhotoSource> photoSource;

@property (assign, nonatomic, readonly) CGRect sourceRect;

@property (strong, nonatomic, readonly) UIImage *transitionPhoto;

@property (assign, nonatomic) BOOL hidesBarsOnTap;

- (instancetype)initWithSourceRect:(CGRect)sourceRect transitionPhoto:(UIImage *)transitionPhoto;

@end
