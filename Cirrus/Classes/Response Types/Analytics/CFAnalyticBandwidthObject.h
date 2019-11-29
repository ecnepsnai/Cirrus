#import "CFAnalyticObject.h"

@interface CFAnalyticBandwidthObject : CFAnalyticObject

@property (strong, nonatomic) NSNumber * all;
@property (strong, nonatomic) NSNumber * cached;
@property (strong, nonatomic) NSNumber * uncached;

@property (strong, nonatomic) NSNumber * min; // Only for totals
@property (strong, nonatomic) NSNumber * max; // Only for totals

@end
