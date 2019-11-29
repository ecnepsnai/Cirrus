#import "CFAnalyticsResults.h"

@implementation CFAnalyticsResults

+ (CFAnalyticsResults *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFAnalyticsResults * results = [CFAnalyticsResults new];
    
    NSArray<NSDictionary<NSString *, id> *> * timeseriesList = [dictionary arrayForKey:@"timeseries"];
    NSMutableArray<CFAnalyticTimeseries *> * timeseries = [NSMutableArray arrayWithCapacity:timeseriesList.count];
    for (NSDictionary<NSString *, id> * ts in timeseriesList) {
        [timeseries addObject:[CFAnalyticTimeseries fromDictionary:ts]];
    }
    results.timeseries = timeseries;
    results.totals = [CFAnalyticTimeseries fromDictionary:[dictionary dictionaryForKey:@"totals"]];
    
    // Calculate the bounds of values for the objects
    CFAnalyticObject * object, * totalObject;
    for (NSString * key in @[@"requests", @"bandwidth", @"visitors", @"threats"]) {
        totalObject = (CFAnalyticObject *)[results.totals valueForKey:key];
        [totalObject setMax:@0];
        [totalObject setMin:@0];

        unsigned long all = 0, min = 0, max = 0;
        
        for (CFAnalyticTimeseries * series in results.timeseries) {
            object = (CFAnalyticObject *)[series valueForKey:key];
            all = [(NSNumber *)[object valueForKey:@"all"] unsignedLongValue];

            if (all > max) {
                max = all;
            }
            
            if (all < min) {
                min = all;
            }
        }
        
        [totalObject setMax:[NSNumber numberWithUnsignedLong:max]];
        [totalObject setMin:[NSNumber numberWithUnsignedLong:min]];
    }

    void (^getTopThree)(CFAnalyticObject *) = ^void(CFAnalyticObject * object) {
        unsigned long long first = 0;
        NSString * firstCountry;
        unsigned long long second = 0;
        NSString * secondCountry;
        unsigned long long third = 0;
        NSString * thirdCountry;
        for (NSString * country in [((CFAnalyticRequestsObject *)object).country allKeys]) {
            unsigned long long total = [[((CFAnalyticRequestsObject *)object).country numberForKey:country] unsignedLongLongValue];
            if (total > first) {
                first = total;
                firstCountry = country;
            } else if (total > second) {
                second = total;
                secondCountry = country;
            } else if (total > third) {
                third = total;
                thirdCountry = country;
            }
        }
        
        NSMutableArray * topThree = [NSMutableArray new];
        unsigned long long all = [((CFAnalyticRequestsObject *)object).all unsignedLongLongValue];
        void (^addCountry)(NSString *, unsigned long long) = ^void(NSString * country, unsigned long long value) {
            if (country) {
                int percentage = (double)value / (double)all * 100;
                NSString * countryName = l(format(@"Country::%@", country));
                [topThree addObject:@[countryName, [NSString stringWithFormat:@"%i%%", percentage]]];
            }
        };

        addCountry(firstCountry, first);
        addCountry(secondCountry, second);
        addCountry(thirdCountry, third);

        ((CFAnalyticRequestsObject *)object).top3Countries = topThree;
    };
    
    getTopThree(results.totals.requests);
    getTopThree(results.totals.threats);

    return results;
}

@end
