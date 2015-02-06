//
//  MessagingLocationCell.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-12-06.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingImageCell.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MessagingLocationCell : MessagingImageCell

@property (strong, nonatomic) CLLocation *location;

@end
