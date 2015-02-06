//
//  NSAttributedString+Messaging.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-23.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "NSAttributedString+Messaging.h"

@implementation NSAttributedString (Messaging)

+ (CGSize)boundingBoxForAttributedString:(NSAttributedString *)attributedString maxWidth:(CGFloat)maxWidth
{
    return [attributedString boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
}

@end
