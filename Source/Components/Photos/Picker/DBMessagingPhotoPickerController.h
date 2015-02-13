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

typedef NS_ENUM(NSInteger, DBMessagingPhotoPickerControllerOption) {
    DBMessagingPhotoPickerControllerOptionPhotoLibrary,
    DBMessagingPhotoPickerControllerOptionTakePhoto,
    DBMessagingPhotoPickerControllerOptionCancel
};

typedef NS_ENUM(NSInteger, DBMessagingPhotoPickerControllerAction) {
    DBMessagingPhotoPickerControllerActionSend,
    DBMessagingPhotoPickerControllerActionComment
};

@class DBMessagingPhotoPickerController;

@protocol DBMessagingPhotoPickerControllerDelegate <NSObject>

@optional

- (void)photoPickerController:(DBMessagingPhotoPickerController *)picker didFinishPickingPhotos:(NSArray *)photos withAction:(DBMessagingPhotoPickerControllerAction)action;

- (void)photoPickerController:(DBMessagingPhotoPickerController *)picker didDismissWithOption:(DBMessagingPhotoPickerControllerOption)option;

@end

NS_CLASS_AVAILABLE_IOS(8_0) @interface DBMessagingPhotoPickerController : UIViewController

@property (weak, nonatomic) id<DBMessagingPhotoPickerControllerDelegate> delegate;

@end
