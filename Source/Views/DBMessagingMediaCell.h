//
//  DBMessagingMediaCell.h
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

@protocol DBMessagingMediaCellDelegate <DBMessagingParentCellDelegate>

@optional
- (void)messageCell:(DBMessagingParentCell *)cell didTapMediaView:(UIView *)mediaView;

@end

@interface DBMessagingMediaCell : DBMessagingParentCell

@property (weak, nonatomic) id<DBMessagingMediaCellDelegate> delegate;

@property (strong, nonatomic) UIView *mediaView;

@end
