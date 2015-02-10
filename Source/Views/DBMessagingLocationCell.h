//
//  DBMessagingLocationCell.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-12-06.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingMediaCell.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface DBMessagingLocationCell : DBMessagingMediaCell

@property (strong, nonatomic) CLLocation *location;

@end
