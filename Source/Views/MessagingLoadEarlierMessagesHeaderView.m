//
//  MessagingLoadEarlierMessagesHeaderView.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-26.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "MessagingLoadEarlierMessagesHeaderView.h"

@interface MessagingLoadEarlierMessagesHeaderView ()

@property (nonatomic) UILabel *loadMoreLabel;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation MessagingLoadEarlierMessagesHeaderView

+ (CGFloat)heightForHeader
{
    return 30.0f;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor lightGrayColor]];
        
        _loadMoreLabel = [[UILabel alloc] init];
        [_loadMoreLabel setTextAlignment:NSTextAlignmentCenter];
        [_loadMoreLabel setNumberOfLines:1];
        [_loadMoreLabel setText:@"Load older messages"];
        [_loadMoreLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:_loadMoreLabel];
    }
    return self;
}

- (void)startAnimating
{
    [self.activityIndicator startAnimating];
}

- (void)stopAnimating
{
    [self.activityIndicator stopAnimating];
}

@end
