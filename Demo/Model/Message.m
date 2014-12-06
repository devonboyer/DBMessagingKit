//
//  Message.m
//  MessagingKit
//
//  Created by Devon Boyer on 2014-09-17.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//

#import "Message.h"

@implementation Message

+ (instancetype)messageWithData:(NSData *)data
                       MIMEType:(MIMEType)MIMEType
                   sentByUserID:(NSString *)sentByUserID
                         sentAt:(NSDate *)sentAt {
    return [[self alloc] initWithData:data MIMEType:MIMEType sentByUserID:sentByUserID sentAt:sentAt];
}

+ (instancetype)messageWithText:(NSString *)text sentByUserID:(NSString *)sentByUserID sentAt:(NSDate *)sentAt {
    return [[self alloc] initWithText:text sentByUserID:sentByUserID sentAt:sentAt];
}

+ (instancetype)messageWithImage:(UIImage *)image sentByUserID:(NSString *)sentByUserID sentAt:(NSDate *)sentAt {
    return [[self alloc] initWithImage:image sentByUserID:sentByUserID sentAt:sentAt];
}

- (instancetype)initWithData:(NSData *)data MIMEType:(MIMEType)MIMEType sentByUserID:(NSString *)senderId sentAt:(NSDate *)date
{
    self = [self init];
    if (self) {
        _data = data;
        _sentByUserID = senderId;
        _sentAt = date;
        _MIMEType = MIMEType;
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text sentByUserID:(NSString *)senderId sentAt:(NSDate *)date
{
    self = [self init];
    if (self) {
        _data = [text dataUsingEncoding:NSUTF8StringEncoding];
        _sentByUserID = senderId;
        _sentAt = date;
        _MIMEType = MIMETypeText;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image sentByUserID:(NSString *)sentByUserID sentAt:(NSDate *)sentAt
{
    self = [self init];
    if (self) {
        _data = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
        _sentByUserID = sentByUserID;
        _sentAt = sentAt;
        _MIMEType = MIMETypeImage;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _data = nil;
        _sentByUserID = @"Unknown";
        _sentAt = [NSDate date];
        _MIMEType = MIMETypeText;
    }
    return self;
}

@end
