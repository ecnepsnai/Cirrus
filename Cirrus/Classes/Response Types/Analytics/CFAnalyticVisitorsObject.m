#import "CFAnalyticVisitorsObject.h"

@implementation CFAnalyticVisitorsObject

+ (id) fromDictionary:(NSDictionary<NSString *,id> *)dictionary {
    CFAnalyticVisitorsObject * analytics = [CFAnalyticVisitorsObject new];

    analytics.searchEngines = [dictionary dictionaryForKey:@"search_engine"];
    
    unsigned long all = [[dictionary numberForKey:@"all"] unsignedLongValue];
    if (analytics.searchEngines) {
        for (NSString * key in [analytics.searchEngines allKeys]) {
            all += [[analytics.searchEngines numberForKey:key] unsignedLongValue];
        }
    }
    
    analytics.all = [NSNumber numberWithUnsignedLong:all];
    
    return analytics;
}

@end
