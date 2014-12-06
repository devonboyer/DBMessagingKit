//
//  MessagingTextCell.h
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-10-10.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingParentCell.h"

@protocol MessagingTextCell <MessagingParentCellDelegate>

@optional
- (void)messageCellDidTapMessageBubble:(MessagingParentCell *)cell;

@end

@interface MessagingTextCell : MessagingParentCell

@property (weak, nonatomic) id <MessagingTextCell> delegate;

@property (strong, nonatomic, readonly) UITextView *messageTextView;

@property (strong, nonatomic) NSString *messageText;

@end
