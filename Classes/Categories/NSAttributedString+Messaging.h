//
//  NSAttributedString+Messaging.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-09-23.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSAttributedString (Messaging)

+ (CGSize)boundingBoxForAttributedString:(NSAttributedString *)attributedString maxWidth:(CGFloat)maxWidth;

@end
