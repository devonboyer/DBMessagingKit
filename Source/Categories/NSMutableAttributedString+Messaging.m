//
//  NSMutableAttributedString+Messaging.m
//  
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2015-02-08.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "NSMutableAttributedString+Messaging.h"

@implementation NSMutableAttributedString (Messaging)

+ (NSMutableAttributedString *)mutableAttributedStringWithAttachment:(NSTextAttachment *)attatchment {
    NSAttributedString *attributedString = [NSAttributedString attributedStringWithAttachment:attatchment];
    return [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
}

@end
