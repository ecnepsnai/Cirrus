#import "OCNumberFormatter.h"

@implementation OCNumberFormatter @end

@implementation OC30MinuteNumberFormatter

- (NSString *) stringForObjectValue:(NSNumber *)obj {
    int time = [obj intValue];
    switch (time) {
        case 0:
          return [lang key:@"{num}min" args:@[@"28"]];
        case 1:
          return [lang key:@"{num}min" args:@[@"21"]];
        case 2:
          return [lang key:@"{num}min" args:@[@"14"]];
        case 3:
          return l(@"Now");
        default:
            return @"";
    }
}

@end

@implementation OC6HourNumberFormatter

- (NSString *) stringForObjectValue:(NSNumber *)obj {
    int time = [obj intValue];
    switch (time) {
        case 0:
            return [lang key:@"{num}hrs" args:@[@"6"]];
        case 12:
            return [lang key:@"{num}hrs" args:@[@"5"]];
        case 24:
            return [lang key:@"{num}hrs" args:@[@"4"]];
        case 36:
            return [lang key:@"{num}hrs" args:@[@"3"]];
        case 48:
            return [lang key:@"{num}hrs" args:@[@"2"]];
        case 60:
            return l(@"Now");
        default:
            return @"";
    }
}

@end

@implementation OCHourNumberFormatter

- (NSString *) stringForObjectValue:(NSNumber *)obj {
    int time = [obj intValue];
    switch (time) {
        case 0:
            return [lang key:@"{num}hrs" args:@[@"24"]];
        case 6:
            return [lang key:@"{num}hrs" args:@[@"18"]];
        case 12:
            return [lang key:@"{num}hrs" args:@[@"12"]];
        case 18:
            return [lang key:@"{num}hrs" args:@[@"6"]];
        case 24:
            return [lang key:@"Now"];
        default:
            return @"";
    }
}

@end

@implementation OCWeekNumberFormatter

- (NSString *) stringForObjectValue:(NSNumber *)obj {
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"E"];

    int time = [obj intValue];
    switch (time) {
        case 0:
            return [formatter stringFromDate:[[NSCalendar currentCalendar]
                                              dateByAddingUnit:NSCalendarUnitDay
                                              value:-7
                                              toDate:[NSDate date]
                                              options:0]];
        case 1:
            return [formatter stringFromDate:[[NSCalendar currentCalendar]
                                              dateByAddingUnit:NSCalendarUnitDay
                                              value:-6
                                              toDate:[NSDate date]
                                              options:0]];
        case 2:
            return [formatter stringFromDate:[[NSCalendar currentCalendar]
                                              dateByAddingUnit:NSCalendarUnitDay
                                              value:-5
                                              toDate:[NSDate date]
                                              options:0]];
        case 3:
            return [formatter stringFromDate:[[NSCalendar currentCalendar]
                                              dateByAddingUnit:NSCalendarUnitDay
                                              value:-4
                                              toDate:[NSDate date]
                                              options:0]];
        case 4:
            return [formatter stringFromDate:[[NSCalendar currentCalendar]
                                              dateByAddingUnit:NSCalendarUnitDay
                                              value:-3
                                              toDate:[NSDate date]
                                              options:0]];
        case 5:
            return [formatter stringFromDate:[[NSCalendar currentCalendar]
                                              dateByAddingUnit:NSCalendarUnitDay
                                              value:-2
                                              toDate:[NSDate date]
                                              options:0]];
        case 6:
            return [formatter stringFromDate:[[NSCalendar currentCalendar]
                                              dateByAddingUnit:NSCalendarUnitDay
                                              value:-1
                                              toDate:[NSDate date]
                                              options:0]];
        default:
            return @"";
    }
}

@end

@implementation OCMonthNumberFormatter

- (NSString *) stringForObjectValue:(NSNumber *)obj {
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"M/d"];

    int time = [obj intValue];
    switch (time) {
        case 0:
            return [formatter stringFromDate:[[NSCalendar currentCalendar]
                                              dateByAddingUnit:NSCalendarUnitMonth
                                              value:-1
                                              toDate:[NSDate date]
                                              options:0]];
        case 6:
            return [formatter stringFromDate:[[NSCalendar currentCalendar]
                                              dateByAddingUnit:NSCalendarUnitDay
                                              value:-24
                                              toDate:[NSDate date]
                                              options:0]];
        case 12:
            return [formatter stringFromDate:[[NSCalendar currentCalendar]
                                              dateByAddingUnit:NSCalendarUnitDay
                                              value:-19
                                              toDate:[NSDate date]
                                              options:0]];
        case 18:
            return [formatter stringFromDate:[[NSCalendar currentCalendar]
                                              dateByAddingUnit:NSCalendarUnitDay
                                              value:-14
                                              toDate:[NSDate date]
                                              options:0]];
        case 24:
            return [formatter stringFromDate:[[NSCalendar currentCalendar]
                                              dateByAddingUnit:NSCalendarUnitDay
                                              value:-4
                                              toDate:[NSDate date]
                                              options:0]];
        case 30:
            return [formatter stringFromDate:[[NSCalendar currentCalendar]
                                              dateByAddingUnit:NSCalendarUnitDay
                                              value:-2
                                              toDate:[NSDate date]
                                              options:0]];
        default:
            return @"";
    }
}

@end

@implementation OCCountNumberFormatter

- (NSString *) stringForObjectValue:(NSNumber *)obj {
    double decimalVal = [obj doubleValue];
    unsigned long long val = decimalVal * [self.max unsignedLongLongValue];
    return [NSString stringWithFormat:@"%llu", val];
}

@end

@implementation OCBandwidthNumberFormatter

- (NSString *) stringForObjectValue:(NSNumber *)obj {
    double decimalVal = [obj doubleValue];
    unsigned long long val = decimalVal * [self.max unsignedLongLongValue];
    return [stringFormatter formatRoundedDecimalBytes:val];
}

@end
