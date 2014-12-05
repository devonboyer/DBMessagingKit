//
//  MessagingPhotoCell.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-10-09.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingParentCell.h"

@protocol MessagingPhotoCellDelegate <MessagingParentCellDelegate>

@optional
- (void)messageCell:(MessagingParentCell *)cell didTapPhotoImageView:(UIImageView *)photoImageView;

@end

@interface MessagingPhotoCell : MessagingParentCell

@property (weak, nonatomic) id<MessagingPhotoCellDelegate> delegate;
@property (strong, nonatomic, readonly) UIImageView *photoImageView;

@end
