#import <Foundation/Foundation.h>

@interface OCNumberFormatter : NSNumberFormatter

@property (strong, nonatomic) NSNumber * min;
@property (strong, nonatomic) NSNumber * max;

@end

@interface OC30MinuteNumberFormatter : OCNumberFormatter @end
@interface OC6HourNumberFormatter : OCNumberFormatter @end
@interface OCHourNumberFormatter : OCNumberFormatter @end
@interface OCWeekNumberFormatter : OCNumberFormatter @end
@interface OCMonthNumberFormatter : OCNumberFormatter @end
@interface OCCountNumberFormatter : OCNumberFormatter @end
@interface OCBandwidthNumberFormatter : OCNumberFormatter @end
