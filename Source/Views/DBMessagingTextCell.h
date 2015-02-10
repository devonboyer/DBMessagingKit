//
//  DBMessagingTextCell.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-10-10.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingParentCell.h"

@protocol DBMessagingTextCellDelegate <DBMessagingParentCellDelegate>

@optional
- (void)messageCell:(DBMessagingParentCell *)cell didTapMessageBubbleImageView:(UIImageView *)messageBubbleImageView;

@end

@interface DBMessagingTextCell : DBMessagingParentCell


@property (weak, nonatomic) id <DBMessagingTextCellDelegate> delegate;

@property (strong, nonatomic, readonly) UITextView *messageTextView;
@property (strong, nonatomic) NSString *messageText;

@end
