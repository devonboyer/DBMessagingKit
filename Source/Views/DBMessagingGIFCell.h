//
//  DBMessagingGIFCell.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-12-07.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingMediaCell.h"

@interface DBMessagingGIFCell : DBMessagingMediaCell

@property (strong, nonatomic) NSData *animatedGIFData;
@property (assign, nonatomic) BOOL animating;

- (void)stopAnimating;
- (void)startAnimating;

@end
