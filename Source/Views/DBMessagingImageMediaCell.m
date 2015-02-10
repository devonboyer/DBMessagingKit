//
//  DBMessagingImageMediaCell.m
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

#import "DBMessagingImageMediaCell.h"

@interface DBMessagingImageMediaCell ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation DBMessagingImageMediaCell

+ (NSString *)mimeType {
    return @"image/jpeg";
}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_imageView setUserInteractionEnabled:YES];
        [_imageView setFrame:self.messageBubbleImageView.frame];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        
        self.mediaView = _imageView;
    }
    return self;
}

@end
