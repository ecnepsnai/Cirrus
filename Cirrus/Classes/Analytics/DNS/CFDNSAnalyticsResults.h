#import <Foundation/Foundation.h>
#import "CFDNSAnalyticsTimeseries.h"

@interface CFDNSAnalyticsResults : NSObject

typedef NS_ENUM(NSUInteger, CFDNSAnalyticsTimeframe) {
    CFDNSAnalyticsTimeframe30Minutes = 0,
    CFDNSAnalyticsTimeframe6Hours,
    CFDNSAnalyticsTimeframe12Hours,
    CFDNSAnalyticsTimeframe24Hours,
};

@property (strong, nonatomic) NSArray<CFDNSAnalyticsTimeseries *> * timeseries;
@property (strong, nonatomic) NSNumber * min;
@property (strong, nonatomic) NSNumber * max;
@property (strong, nonatomic) NSNumber * total;
@property (strong, nonatomic) NSNumber * totalError;

/**
 If there was an instance of NXDOMAIN somewhere in the timeseries we set this to true
 to know when to display the other plot on the graph
 */
@property (nonatomic)         BOOL       hasErrorResponse;

+ (CFDNSAnalyticsResults *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;

@end
