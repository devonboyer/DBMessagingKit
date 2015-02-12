//
//  DBMessagingLocationMediaCell.m
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

#import "DBMessagingLocationMediaCell.h"

#import "DBMessagingLocationPin.h"

#define METERS_PER_MILE 1609.344

static NSString *kDBMessagingLocationMediaCellMimeType = @"geo";


@interface DBMessagingLocationMediaCell () <MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;

@end

@implementation DBMessagingLocationMediaCell

+ (NSString *)mimeType {
    return kDBMessagingLocationMediaCellMimeType;
}

+ (void)setMimeType:(NSString *)mimeType {
    NSAssert(![mimeType isEqualToString:@""] || mimeType != nil, @"Mime type for class %@ cannot be nil.", [self class]);
    kDBMessagingLocationMediaCellMimeType = mimeType;
}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mapView = [[MKMapView alloc] init];
        [_mapView setZoomEnabled:YES];
        [_mapView setScrollEnabled:YES];
        [_mapView setShowsUserLocation:YES];
        
        self.mediaView = _mapView;
    }
    return self;
}

#pragma mark - Setters

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    _coordinate = coordinate;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    [_mapView setRegion:viewRegion animated:YES];
    
    // Create an annotation
    DBMessagingLocationPin *annotation = [[DBMessagingLocationPin alloc] initWithCoordinate:coordinate];
    [_mapView addAnnotation:annotation];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

     if ([annotation isKindOfClass:[DBMessagingLocationPin class]]) {
         
         MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:[DBMessagingLocationPin annotationReuseIdentifier]];
         annotationView.enabled = YES;
         annotationView.canShowCallout = YES;
         annotationView.annotation = annotation;
         return annotationView;
     }
    
    return nil;
}

@end
