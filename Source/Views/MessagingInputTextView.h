//
//  MessagingInputTextView.h
//  
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-18.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

@protocol MessagingInputTextViewDelegate <UITextViewDelegate>

@optional
- (void)textViewDidChangeFrame:(UITextView *)textView delta:(CGFloat)delta;

@end

@interface MessagingInputTextView : UITextView <UIAppearance>

@property (weak, nonatomic) id <MessagingInputTextViewDelegate> delegate;

@property (assign, nonatomic) CGFloat topLayoutGuide;
@property (assign, nonatomic) NSInteger borderWidth UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) NSInteger cornerRadius UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) NSString *placeholderText UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *placeholderColor UI_APPEARANCE_SELECTOR;

- (NSString *)currentlyComposedText;

@end
