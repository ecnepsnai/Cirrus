#import "CFAnalyticThreatsObject.h"

@implementation CFAnalyticThreatsObject

+ (id) fromDictionary:(NSDictionary<NSString *,id> *)dictionary {
    CFAnalyticThreatsObject * analytics = [CFAnalyticThreatsObject new];
    
    analytics.type = [dictionary dictionaryForKey:@"type"];
    analytics.country = [dictionary dictionaryForKey:@"country"];
    analytics.all = [dictionary numberForKey:@"all"];
    
    analytics.country = [dictionary dictionaryForKey:@"country"];
    
    return analytics;
}

@end
