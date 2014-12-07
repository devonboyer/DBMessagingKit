//
//  MessagingLocationCell.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-12-06.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingPhotoCell.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@protocol MessagingLocationCellDelegate <MessagingParentCellDelegate>

@optional
- (void)messageCell:(MessagingParentCell *)cell didTapMapImageView:(UIImageView *)mapView withLocation:(CLLocation *)location coordinateRegion:(MKCoordinateRegion)coordinateRegion;

@end

@interface MessagingLocationCell : MessagingPhotoCell

@property (strong, nonatomic) CLLocation *location;

@end
