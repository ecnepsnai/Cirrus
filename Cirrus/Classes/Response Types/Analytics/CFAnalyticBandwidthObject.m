#import "CFAnalyticBandwidthObject.h"

@implementation CFAnalyticBandwidthObject

+ (id) fromDictionary:(NSDictionary<NSString *,id> *)dictionary {
    CFAnalyticBandwidthObject * analytics = [CFAnalyticBandwidthObject new];
    
    analytics.all = [dictionary numberForKey:@"all"];
    analytics.cached = [dictionary numberForKey:@"cached"];
    analytics.uncached = [dictionary numberForKey:@"uncached"];
    
    return analytics;
}

@end
