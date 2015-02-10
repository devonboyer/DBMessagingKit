//
//  DBMessagingLocationPin.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2015-02-10.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface DBMessagingLocationPin : NSObject <MKAnnotation>

+ (NSString *)annotationReuseIdentifier;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
