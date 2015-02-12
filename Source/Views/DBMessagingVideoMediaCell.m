//
//  DBMessagingVideoMediaCell.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2015-02-09.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingVideoMediaCell.h"

static NSString *kDBMessagingVideoMediaCellMimeType = @"video/mp4";

@interface DBMessagingVideoMediaCell ()

@end

@implementation DBMessagingVideoMediaCell

+ (NSString *)mimeType {
    return kDBMessagingVideoMediaCellMimeType;
}

+ (void)setMimeType:(NSString *)mimeType {
    NSAssert(![mimeType isEqualToString:@""] || mimeType != nil, @"Mime type for class %@ cannot be nil.", [self class]);
    kDBMessagingVideoMediaCellMimeType = mimeType;
}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


@end
