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

@interface DBMessagingVideoMediaCell ()

@end

@implementation DBMessagingVideoMediaCell

+ (NSString *)mimeType {
    return @"video/mp4";
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
