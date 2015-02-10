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
 * The key to access the mime type in a message part.
 */
static NSString *const DBMessagePartMIMEKey = @"mime";

/**
 * The key to access the value in a message part.
 */
static NSString *const DBMessagePartValueKey = @"value";

/**
 * Specifys the type of layout in which to display timestamps.
 *
 * @see DBMessagingCollectionViewHiddenTimestampFlowLayout
 * @see DBMessagingCollectionViewSlidingTimestampFlowLayout
 */
typedef NS_ENUM(NSUInteger, DBMessagingTimestampStyle) {
    DBMessagingTimestampStyleNone,
    DBMessagingTimestampStyleHidden,
    DBMessagingTimestampStyleSliding
};

