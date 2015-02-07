//
//  DBMessagingInputUtility.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-10-22.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

/**
 *  The 'DBMessagingInputUtility' protocol defines the common interface through which 'DBMessagingViewController'
 *  interacts with the input view.
 *
 *  It declares the required and optional methods that a class must implement so that instances of that class
 *  can be displayed properly with an 'DBMessagingViewController'.
 *
 *  @see 'DBMessagingViewController'
 */
@protocol DBMessagingInputUtility <NSObject>

@required
/**
 *  @return The send button used in the message input view
 *
 *  @warning You must not return 'nil' from this method.
 */
- (UIButton *)sendButton;

/**
 *  @return The text view used in the message input view.
 *
 *  @warning You must not return 'nil' from this method.
 */
- (UITextView *)textView;

@end
