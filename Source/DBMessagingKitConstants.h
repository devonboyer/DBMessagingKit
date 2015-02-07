//
//  DBMessagingKitConstants.h
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-30.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>

/**
 * A MIME Type (Internet Media Type) identifying the type of data contained in the given message object.
 */
typedef NS_ENUM(NSUInteger, MIMEType) {
    MIMETypeText,
    MIMETypeImage,
    MIMETypeMovie,
    MIMETypeGIF,
    MIMETypeLocation
};

