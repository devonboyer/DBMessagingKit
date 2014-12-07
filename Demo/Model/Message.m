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

+ (instancetype)messageWithLocation:(CLLocation *)location
                       sentByUserID:(NSString *)sentByUserID
                             sentAt:(NSDate *)sentAt {
    return [[self alloc] initWithLocation:location sentByUserID:sentByUserID sentAt:sentAt];
}

+ (instancetype)messageWithText:(NSString *)text
                   sentByUserID:(NSString *)sentByUserID
                         sentAt:(NSDate *)sentAt {
    return [[self alloc] initWithText:text sentByUserID:sentByUserID sentAt:sentAt];
}

+ (instancetype)messageWithImage:(UIImage *)image
                    sentByUserID:(NSString *)sentByUserID
                          sentAt:(NSDate *)sentAt {
    return [[self alloc] initWithImage:image sentByUserID:sentByUserID sentAt:sentAt];
}

- (instancetype)initWithLocation:(CLLocation *)location sentByUserID:(NSString *)sentByUserID sentAt:(NSDate *)sentAt
{
    self = [self initWithMIMEType:MIMETypeLocation sentByUserID:sentByUserID sentAt:sentAt];
    if (self) {
        _location = location;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data MIMEType:(MIMEType)MIMEType sentByUserID:(NSString *)sentByUserID sentAt:(NSDate *)sentAt
{
    self = [self initWithMIMEType:MIMEType sentByUserID:sentByUserID sentAt:sentAt];
    if (self) {
        _data = data;
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text sentByUserID:(NSString *)sentByUserID sentAt:(NSDate *)sentAt
{
    self = [self initWithMIMEType:MIMETypeText sentByUserID:sentByUserID sentAt:sentAt];
    if (self) {
        _data = [text dataUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image sentByUserID:(NSString *)sentByUserID sentAt:(NSDate *)sentAt
{
    self = [self initWithMIMEType:MIMETypeImage sentByUserID:sentByUserID sentAt:sentAt];
    if (self) {
        _data = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
    }
    return self;
}

- (instancetype)initWithMIMEType:(MIMEType)MIMEType sentByUserID:(NSString *)sentByUserID sentAt:(NSDate *)sentAt
{
    self = [self init];
    if (self) {
        _sentByUserID = sentByUserID;
        _sentAt = sentAt;
        _MIMEType = MIMEType;
    }
    return self;
}

@end
