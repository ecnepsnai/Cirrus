#import <Foundation/Foundation.h>

#import "CFAnalyticTimeseries.h"

@interface CFAnalyticsResults : NSObject

typedef NS_ENUM(NSUInteger, CFAnalyticsTimeframe) {
    CFAnalyticsTimeframe24Hours = 0,
    CFAnalyticsTimeframeLastWeek,
    CFAnalyticsTimeframeLastMonth
};

@property (strong, nonatomic) NSArray<CFAnalyticTimeseries *> * timeseries;
@property (strong, nonatomic) CFAnalyticTimeseries * totals;

+ (CFAnalyticsResults *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;

@end
