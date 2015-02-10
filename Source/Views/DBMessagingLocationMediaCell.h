//
//  DBMessagingLocationMediaCell.h
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

#import "DBMessagingMediaCell.h"

#import <MapKit/MapKit.h>

@class MKMapView;

@interface DBMessagingLocationMediaCell : DBMessagingMediaCell

@property (strong, nonatomic, readonly) MKMapView *mapView;

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

@end
