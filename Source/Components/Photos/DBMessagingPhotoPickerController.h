//
//  DBMessagingPhotoPickerController.h
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

#import <UIKit/UIKit.h>

@class DBMessagingPhotoPickerController;

@protocol DBMessagingPhotoPickerControllerDelegate <NSObject>

@optional

- (void)photoPickerController:(DBMessagingPhotoPickerController *)picker didFinishPickingPhotos:(NSArray *)photos;

- (void)photoPickerControllerDidCancel:(DBMessagingPhotoPickerController *)picker;

@end

NS_CLASS_AVAILABLE_IOS(8_0) @interface DBMessagingPhotoPickerController : UIViewController

@property (weak, nonatomic) id<DBMessagingPhotoPickerControllerDelegate> delegate;

@property (strong, nonatomic, readonly) NSArray *selectedPhotos;

@end
