//
//  MessagingTimestampSupplementaryView.h
//  MessagingKit
//
//  GitHub
//  https://github.com/DevonBoyer/MessagingKit
//
//  Created by Devon Boyer on 2014-10-11.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessagingParentCell.h"

@interface MessagingTimestampSupplementaryView : UICollectionReusableView

@property (strong, nonatomic, readonly) UILabel *timestampLabel;
@property (assign, nonatomic) MessageBubbleType type;

@end
