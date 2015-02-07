//
//  DBMessagingImageCell.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-10-09.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingParentCell.h"

@protocol DBMessagingImageCellDelegate <DBMessagingParentCellDelegate>

@optional
- (void)messageCell:(DBMessagingParentCell *)cell didTapImageView:(UIImageView *)imageView;

@end

@interface DBMessagingImageCell : DBMessagingParentCell

@property (weak, nonatomic) id<DBMessagingImageCellDelegate> delegate;
@property (strong, nonatomic, readonly) UIImageView *imageView;

@end
