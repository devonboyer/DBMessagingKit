//
//  MessagingVideoCell.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-12-06.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingPhotoCell.h"

@protocol MessagingTextCell <MessagingPhotoCellDelegate>

@optional
- (void)messageCellDidPlayVideo:(MessagingParentCell *)cell;

@end

@interface MessagingVideoCell : MessagingPhotoCell

@end
