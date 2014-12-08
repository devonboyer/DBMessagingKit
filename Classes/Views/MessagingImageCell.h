//
//  MessagingPhotoCell.h
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-10-09.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingParentCell.h"

@protocol MessagingImageCellDelegate <MessagingParentCellDelegate>

@optional
- (void)messageCell:(MessagingParentCell *)cell didTapImageView:(UIImageView *)imageView;

@end

@interface MessagingImageCell : MessagingParentCell

@property (weak, nonatomic) id<MessagingImageCellDelegate> delegate;
@property (strong, nonatomic, readonly) UIImageView *imageView;

@end
