#import "CFAnalyticObject.h"

@interface CFAnalyticVisitorsObject : CFAnalyticObject

@property (strong, nonatomic) NSNumber * all;
@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> * searchEngines;

@property (strong, nonatomic) NSNumber * min; // Only for totals
@property (strong, nonatomic) NSNumber * max; // Only for totals

@end
