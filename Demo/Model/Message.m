//
//  Message.m
//  MessagingKit
//
//  Created by Devon Boyer on 2014-09-17.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "Message.h"

@implementation Message

- (instancetype)initWithValue:(id)value mime:(NSString *)mime sentByUserID:(NSString *)sentByUserID sentAt:(NSDate *)sentAt {
    self = [self init];
    if (self) {
        _sentByUserID = sentByUserID;
        _sentAt = sentAt;
        _mime = mime;
        _value = value;
    }
    return self;
}

@end
