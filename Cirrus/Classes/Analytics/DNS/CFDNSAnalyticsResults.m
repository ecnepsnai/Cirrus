#import "CFDNSAnalyticsResults.h"

@implementation CFDNSAnalyticsResults

+ (CFDNSAnalyticsResults *) fromDictionary:(NSDictionary<NSString *,id> *)dictionary {
    CFDNSAnalyticsResults * results = [CFDNSAnalyticsResults new];

    NSDictionary<NSString *, NSNumber *> * min = [dictionary dictionaryForKey:@"min"];
    NSDictionary<NSString *, NSNumber *> * max = [dictionary dictionaryForKey:@"max"];
    NSDictionary<NSString *, NSNumber *> * totals = [dictionary dictionaryForKey:@"totals"];

    if (min) {
        results.min = [min numberForKey:@"queryCount"];
    }
    if (max) {
        results.max = [max numberForKey:@"queryCount"];
    }
    if (totals) {
        results.total = [totals numberForKey:@"queryCount"];
    }

    NSArray<NSDictionary<NSString *, id> *> * data = [dictionary arrayForKey:@"data"];
    if (data == nil) {
        return nil;
    }

    NSMutableArray<CFDNSAnalyticsTimeseries *> * timeseriesList = [NSMutableArray new];

    NSUInteger totalError = 0;

    for (NSDictionary<NSString *, id> * series in data) {
        NSString * code = [[series arrayForKey:@"dimensions"] stringAtIndex:0];
        NSArray * metrics = [[series arrayForKey:@"metrics"] arrayAtIndex:0];
        NSNumber * dataPoint;
        for (NSUInteger i = 0, count = metrics.count; i < count; i++) {
            dataPoint = [metrics objectAtIndex:i];

            if (![timeseriesList objectAtUnsafeIndex:i]) {
                [timeseriesList addObject:[CFDNSAnalyticsTimeseries new]];
            }

            CFDNSAnalyticsTimeseries * timeseries = [timeseriesList objectAtIndex:i];
            [timeseries setCount:dataPoint forResponseCode:code];

            if ([timeseries.nxdomainCount unsignedIntegerValue] > 0) {
                results.hasErrorResponse = YES;
                totalError += [timeseries.nxdomainCount unsignedIntegerValue];
            }
        }
    }

    results.timeseries = timeseriesList;
    results.totalError = [NSNumber numberWithUnsignedInteger:totalError];

    return results;
}

@end
