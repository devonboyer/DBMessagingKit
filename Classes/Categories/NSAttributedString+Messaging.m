//
//  NSAttributedString+Messaging.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-09-23.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "NSAttributedString+Messaging.h"

@implementation NSAttributedString (Messaging)

+ (CGSize)boundingBoxForAttributedString:(NSAttributedString *)attributedString maxWidth:(CGFloat)maxWidth
{
    return [attributedString boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
}

@end
