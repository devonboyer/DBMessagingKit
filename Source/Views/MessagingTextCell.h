//
//  MessagingTextCell.h
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

#import "MessagingParentCell.h"

@protocol MessagingTextCellDelegate <MessagingParentCellDelegate>

@optional
- (void)messageCell:(MessagingParentCell *)cell didTapMessageBubbleImageView:(UIImageView *)messageBubbleImageView;

@end

@interface MessagingTextCell : MessagingParentCell

@property (weak, nonatomic) id <MessagingTextCellDelegate> delegate;

@property (strong, nonatomic, readonly) UITextView *messageTextView;

@property (strong, nonatomic) NSString *messageText;

@end
