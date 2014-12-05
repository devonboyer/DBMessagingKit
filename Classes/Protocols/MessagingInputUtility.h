//
//  MessagingInputUtility.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-10-22.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IGMessageingInputTextView;

/**
 *  The 'IGMessageInputUtility' protocol defines the common interface through which 'IGChatManagerViewController'
 *  interacts with the input view.
 *
 *  It declares the required and optional methods that a class must implement so that instances of that class
 *  can be displayed properly with an 'IGChatManagerViewController'.
 *
 *  @see 'IGChatManagerViewController'
 */
@protocol MessagingInputUtility <NSObject>

@required
- (UIButton *)sendButton;
- (UITextView *)textView;

@end
