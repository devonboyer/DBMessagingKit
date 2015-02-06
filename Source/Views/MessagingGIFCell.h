//
//  MessagingGIFCell.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-12-07.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingImageCell.h"

@interface MessagingGIFCell : MessagingImageCell

@property (strong, nonatomic) NSData *animatedGIFData;
@property (assign, nonatomic) BOOL animating;

- (void)stopAnimating;
- (void)startAnimating;

@end
