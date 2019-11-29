#import "CFAnalyticTimeseries.h"

@implementation CFAnalyticTimeseries

+ (CFAnalyticTimeseries *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFAnalyticTimeseries * timeSeries = [CFAnalyticTimeseries new];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    timeSeries.startDate = [formatter dateFromString:[dictionary stringForKey:@"since"]];
    timeSeries.endDate = [formatter dateFromString:[dictionary stringForKey:@"until"]];
    
    timeSeries.requests = [CFAnalyticRequestsObject fromDictionary:[dictionary dictionaryForKey:@"requests"]];
    timeSeries.visitors = [CFAnalyticVisitorsObject fromDictionary:[dictionary dictionaryForKey:@"pageviews"]];
    timeSeries.bandwidth = [CFAnalyticBandwidthObject fromDictionary:[dictionary dictionaryForKey:@"bandwidth"]];
    timeSeries.threats = [CFAnalyticThreatsObject fromDictionary:[dictionary dictionaryForKey:@"threats"]];
    
    return timeSeries;
}

@end
