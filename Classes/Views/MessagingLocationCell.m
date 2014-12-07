//
//  MessagingLocationCell.m
//  MessagingKit
//
//  Created by Devon Boyer on 2014-12-06.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "MessagingLocationCell.h"
#import "MessagingCollectionViewLayoutAttributes.h"

typedef void (^MessagingLocationCompletionBlock)(void);

@interface MessagingLocationCell ()

@property (strong, nonatomic) UIImage *cachedMapSnapshotImage;

@property (assign, nonatomic) CGSize incomingLocationMapSize;
@property (assign, nonatomic) CGSize outgoingLocationMapSize;

@end

@implementation MessagingLocationCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch (self.type) {
        case MessageBubbleTypeIncoming: {
            
            CGFloat mapWidth = self.incomingLocationMapSize.width;
            
            [self.messageBubbleImageView setFrame:CGRectMake(self.incomingAvatarSize.width + self.incomingMessageBubbleAvatarSpacing,
                                                             CGRectGetMaxY(self.messageTopLabel.frame),
                                                             mapWidth,
                                                             CGRectGetHeight(self.frame) - self.cellTopLabelHeight - self.messageTopLabelHeight - self.cellBottomLabelHeight)];
            break;
        }
        case MessageBubbleTypeOutgoing: {
            
            CGFloat mapWidth = self.outgoingLocationMapSize.width;
            
            [self.messageBubbleImageView setFrame:CGRectMake(CGRectGetWidth(self.frame) - mapWidth - self.outgoingAvatarSize.width - self.outgoingMessageBubbleAvatarSpacing,
                                                             CGRectGetMaxY(self.messageTopLabel.frame),
                                                             mapWidth,
                                                             CGRectGetHeight(self.frame) - self.cellTopLabelHeight - self.messageTopLabelHeight - self.cellBottomLabelHeight)];
            break;
        }
        default:
            break;
    }
}

- (void)applyLayoutAttributes:(MessagingCollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    self.incomingLocationMapSize = layoutAttributes.incomingLocationMapSize;
    self.outgoingLocationMapSize = layoutAttributes.outgoingLocationMapSize;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _cachedMapSnapshotImage = nil;
}

#pragma mark - Setters

- (void)setLocation:(CLLocation *)location {
    _location = location;
    
    if (!_cachedMapSnapshotImage) {
        CLLocationDegrees latitude = location.coordinate.latitude;
        CLLocationDegrees longitude = location.coordinate.longitude;
        CLLocationCoordinate2D coordinateOrigin = CLLocationCoordinate2DMake(latitude, longitude);
        CLLocationCoordinate2D coordinateMax = CLLocationCoordinate2DMake(latitude + [self mapSize].width, longitude + [self mapSize].height);

        MKMapPoint upperLeft = MKMapPointForCoordinate(coordinateOrigin);
        MKMapPoint lowerRight = MKMapPointForCoordinate(coordinateMax);

        MKMapRect mapRect = MKMapRectMake(upperLeft.x,
                                          upperLeft.y,
                                          lowerRight.x - upperLeft.x,
                                          lowerRight.y - upperLeft.y);

        [self createMapViewSnapshotForLocation:location coordinateRegion:MKCoordinateRegionForMapRect(MKMapRectWorld) withCompletionHandler:^{
            self.photoImageView.image = _cachedMapSnapshotImage;
        }];
    }
}

- (void)createMapViewSnapshotForLocation:(CLLocation *)location
                        coordinateRegion:(MKCoordinateRegion)region
                   withCompletionHandler:(MessagingLocationCompletionBlock)completion
{
    NSParameterAssert(location != nil);
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = region;
    options.size = [self mapSize];
    options.scale = [UIScreen mainScreen].scale;
    
    MKMapSnapshotter *mapSnapShotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    
    [mapSnapShotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                 completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
                     if (error) {
                         NSLog(@"%s Error creating map snapshot: %@", __PRETTY_FUNCTION__, error);
                         return;
                     }
                     
                     MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];
                     CGPoint coordinatePoint = [snapshot pointForCoordinate:location.coordinate];
                     UIImage *image = snapshot.image;
                     
                     UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
                     {
                         [image drawAtPoint:CGPointZero];
                         [pin.image drawAtPoint:coordinatePoint];
                         self.cachedMapSnapshotImage = UIGraphicsGetImageFromCurrentImageContext();
                     }
                     UIGraphicsEndImageContext();
                     
                     if (completion) {
                         dispatch_async(dispatch_get_main_queue(), completion);
                     }
                 }];
}

- (CGSize)mapSize {
    switch (self.type) {
        case MessageBubbleTypeIncoming:
            return _incomingLocationMapSize;
        case MessageBubbleTypeOutgoing:
            return _outgoingLocationMapSize;
    }
}

@end
