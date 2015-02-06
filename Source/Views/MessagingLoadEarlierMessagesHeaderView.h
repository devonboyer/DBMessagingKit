//
//  MessagingLoadEarlierMessagesHeaderView.h
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-09-26.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagingLoadEarlierMessagesHeaderView : UICollectionReusableView

+ (CGFloat)heightForHeader;

- (void)startAnimating;
- (void)stopAnimating;

@end
