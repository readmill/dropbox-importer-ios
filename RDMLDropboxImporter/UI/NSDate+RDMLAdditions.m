//
//  NSDate+RMAdditions.m
//  Readmill
//
//  Created by Martin Hwasser on 07/03/14.
//  Copyright (c) 2014 Readmill. All rights reserved.
//

#import "NSDate+RDMLAdditions.h"

@implementation NSDate (RDMLAdditions)

- (NSString *)timeAgo
{
    static NSCalendar *calendar = nil;
    NSDateComponents *dateComponents = nil;
    if (!calendar) {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    
    NSUInteger components = NSYearCalendarUnit|NSMonthCalendarUnit|
                NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit;
        
    dateComponents = [calendar components:components
                                 fromDate:self 
                                   toDate:[NSDate date] 
                                  options:0];
    
    NSInteger year, month, day, hour, minute;
    year = [dateComponents year];
    month = [dateComponents month];
    day = [dateComponents day];
    hour = [dateComponents hour];
    minute = [dateComponents minute];

    NSString *timeAgo = nil;
    if (year) {
        timeAgo = [NSString stringWithFormat:@"%ld year%@ ago", (long)year, (year == 1) ? @"" : @"s"];
    } else if (month) {
        timeAgo = [NSString stringWithFormat:@"%ld month%@ ago", (long)month, (month == 1) ? @"" : @"s"];
    } else if (day) {
        if (day == 1) {
            timeAgo = @"Yesterday";
        } else {
            timeAgo = [NSString stringWithFormat:@"%ld days ago", (long)day];    
        }
    } else if (hour) {
        timeAgo = [NSString stringWithFormat:@"%ld hour%@ ago", (long)hour, (hour == 1) ? @"" : @"s"];
    } else if (minute) {
        timeAgo = [NSString stringWithFormat:@"%ld minute%@ ago", (long)minute, (minute == 1) ? @"" : @"s"];
    } else {
        timeAgo = @"Just now";
    }
    return timeAgo;
}

@end
