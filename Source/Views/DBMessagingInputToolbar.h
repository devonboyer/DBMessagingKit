//
//  DBMessageInputView.h
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

#import <UIKit/UIKit.h>

@class DBMessagingInputToolbar;
@class DBMessagingInputTextView;

typedef NS_ENUM(NSInteger, DBMessagingInputToolbarItemPosition) {
    DBMessagingInputToolbarItemPositionLeft,
    DBMessagingInputToolbarItemPositionRight
    // DBMessagingInputToolbarItemPositionBottom - In development
    // DBMessagingInputToolbarItemPositionTop - In development
};

@interface DBMessagingInputToolbar : UIView

@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) NSInteger borderWidth;
@property (assign, nonatomic) BOOL blur;

@property (strong, nonatomic) UIBarButtonItem *sendBarButtonItem;
@property (strong, nonatomic, readonly) UIToolbar *contentToolbar;
@property (strong, nonatomic, readonly) DBMessagingInputTextView *textView;

- (void)addItem:(UIBarButtonItem *)item position:(DBMessagingInputToolbarItemPosition)position animated:(BOOL)animated;
- (void)toggleSendButtonEnabled;

@end
