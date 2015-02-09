//
//  Message.h
//  MessagingKit
//
//  Created by Devon Boyer on 2014-09-17.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DBMessagingKitConstants.h"

@interface Message : NSObject

@property (strong, nonatomic) NSString *sentByUserID;
@property (strong, nonatomic) NSDate *sentAt;
@property (assign, nonatomic) NSString *mime;
@property (strong, nonatomic) NSData *value;

- (instancetype)initWithValue:(id)value
                         mime:(NSString *)mime
                 sentByUserID:(NSString *)sentByUserID
                       sentAt:(NSDate *)sentAt;

@end
