//
//  DBMessagingCollectionViewFlowLayoutInvalidationContext.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-09-23.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingCollectionViewFlowLayoutInvalidationContext.h"

@implementation DBMessagingCollectionViewFlowLayoutInvalidationContext

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.invalidateFlowLayoutDelegateMetrics = NO;
        self.invalidateFlowLayoutAttributes = NO;
        _emptyCache = NO;
    }
    return self;
}

+ (instancetype)context
{
    DBMessagingCollectionViewFlowLayoutInvalidationContext *context = [[DBMessagingCollectionViewFlowLayoutInvalidationContext alloc] init];
    context.invalidateFlowLayoutDelegateMetrics = YES;
    context.invalidateFlowLayoutAttributes = YES;
    return context;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: invalidateFlowLayoutDelegateMetrics=%d, invalidateFlowLayoutAttributes=%d, invalidateDataSourceCounts=%d>",
            [self class],
            self.invalidateFlowLayoutDelegateMetrics,
            self.invalidateFlowLayoutAttributes,
            self.invalidateDataSourceCounts];
}

@end
