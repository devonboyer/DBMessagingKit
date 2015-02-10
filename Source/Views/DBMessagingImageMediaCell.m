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

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_imageView setClipsToBounds:YES];
        [_imageView setUserInteractionEnabled:YES];
        [_imageView setFrame:self.messageBubbleImageView.frame];
        [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [_imageView setImage:nil];
        [self.messageBubbleImageView addSubview:_imageView];
        
        self.mediaView = _imageView;
    }
    return self;
}

@end
