//
//  DBMessagingLocationPin.m
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

#import "DBMessagingLocationPin.h"

#import <AddressBook/AddressBook.h>

@interface DBMessagingLocationPin ()

@end

@implementation DBMessagingLocationPin

+ (NSString *)annotationReuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
    }
    return self;
}

- (MKMapItem*)mapItem {
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:_coordinate addressDictionary:nil];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}

@end
