//
//  DBMessagingTimestampFormatter.m
//
//
//  GitHub
//  https://github.com/DevonBoyer/DBMessagingKit
//
//
//  Created by Devon Boyer on 2014-10-25.
//  Copyright (c) 2014 Devon Boyer. All rights reserved.
//
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DBMessagingTimestampFormatter.h"

@interface DBMessagingTimestampFormatter ()

@property (strong, nonatomic, readwrite) NSDateFormatter *dateFormatter;

@end

@implementation DBMessagingTimestampFormatter

#pragma mark - Singleton

+ (instancetype)sharedFormatter
{
    static DBMessagingTimestampFormatter *sharedFormatter = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedFormatter = [[self alloc] init];
    });
    
    return sharedFormatter;
}

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setDoesRelativeDateFormatting:YES];
        
        UIColor *color = [UIColor lightGrayColor];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        _dateTextAttributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0f],
                                 NSForegroundColorAttributeName : color,
                                 NSParagraphStyleAttributeName : paragraphStyle };
        
        _timeTextAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:12.0f],
                                 NSForegroundColorAttributeName : color,
                                 NSParagraphStyleAttributeName : paragraphStyle };
    }
    return self;
}


#pragma mark - Formatter

- (NSString *)timestampForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [self.dateFormatter stringFromDate:date];
}

- (NSAttributedString *)attributedTimestampForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    [_dateFormatter setDoesRelativeDateFormatting:YES];
    
    NSString *relativeDate = [self relativeDateForDate:date];
    NSString *time = [self timeForDate:date];
    
    NSMutableAttributedString *timestamp = [[NSMutableAttributedString alloc] initWithString:relativeDate
                                                                                  attributes:self.dateTextAttributes];
    
    [timestamp appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    
    [timestamp appendAttributedString:[[NSAttributedString alloc] initWithString:time
                                                                      attributes:self.timeTextAttributes]];
    
    return [[NSAttributedString alloc] initWithAttributedString:timestamp];
}

- (NSString *)timeForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    [_dateFormatter setDoesRelativeDateFormatting:YES];
    
    [self.dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [self.dateFormatter stringFromDate:date];
}

- (NSString *)relativeDateForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    [_dateFormatter setDoesRelativeDateFormatting:YES];
    
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return [self.dateFormatter stringFromDate:date];
}

- (NSString *)verboseTimestampForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    [_dateFormatter setDoesRelativeDateFormatting:NO];
    
    NSInteger year = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:date] year];
    NSInteger currentYear = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]] year];
    
    if (year == currentYear) {
        [self.dateFormatter setDateFormat:@"EEE, MMM dd, h:mm a"];
    }
    else {
        [self.dateFormatter setDateFormat:@"EEE, MMM dd, YYYY hh:mm a"];
    }
    
    return [NSString stringWithFormat:@"Sent on %@", [self.dateFormatter stringFromDate:date]];
}

@end
