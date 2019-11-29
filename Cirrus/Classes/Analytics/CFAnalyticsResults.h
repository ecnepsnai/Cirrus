#import <Foundation/Foundation.h>

#import "CFAnalyticTimeseries.h"

@interface CFAnalyticsResults : NSObject

typedef NS_ENUM(NSUInteger, CFAnalyticsTimeframe) {
    CFAnalyticsTimeframe6Hours = 0,
    CFAnalyticsTimeframe12Hours,
    CFAnalyticsTimeframe24Hours,
    CFAnalyticsTimeframeLastWeek,
    CFAnalyticsTimeframeLastMonth
};

@property (strong, nonatomic) NSArray<CFAnalyticTimeseries *> * timeseries;
@property (strong, nonatomic) CFAnalyticTimeseries * totals;

+ (CFAnalyticsResults *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;

@end
