//
//  DBMessagingTimestampSupplementaryView.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-10-11.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import "DBMessagingParentCell.h"
#import "DBMessagingKitConstants.h"

@interface DBMessagingTimestampSupplementaryView : UICollectionReusableView

@property (strong, nonatomic, readonly) UILabel *timestampLabel;
@property (assign, nonatomic) MessageBubbleType type;
@property (assign, nonatomic) DBMessagingTimestampStyle timestampStyle;

@end
