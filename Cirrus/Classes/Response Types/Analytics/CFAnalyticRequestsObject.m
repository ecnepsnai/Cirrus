#import "CFAnalyticRequestsObject.h"

@implementation CFAnalyticRequestsObject

+ (id) fromDictionary:(NSDictionary<NSString *,id> *)dictionary {
    CFAnalyticRequestsObject * analytics = [CFAnalyticRequestsObject new];
    
    analytics.all = [dictionary numberForKey:@"all"];
    analytics.cached = [dictionary numberForKey:@"cached"];
    analytics.uncached = [dictionary numberForKey:@"uncached"];
    
    NSDictionary<NSString *, NSNumber *> * ssl = [dictionary dictionaryForKey:@"ssl"];
    if (ssl) {
        analytics.encrypted = [ssl numberForKey:@"encrypted"];
        analytics.uncached = [ssl numberForKey:@"unencrypted"];
    } else {
        analytics.encrypted = @0;
        analytics.uncached = @0;
    }
    
    analytics.country = [dictionary dictionaryForKey:@"country"];
    
    return analytics;
}

@end
