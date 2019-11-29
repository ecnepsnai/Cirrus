#import "CFAnalyticObject.h"

@interface CFAnalyticThreatsObject : CFAnalyticObject

@property (strong, nonatomic) NSDictionary<NSString *, NSString *> * type;
@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> * country;
@property (strong, nonatomic) NSArray<NSArray<id> *> * top3Countries;
@property (strong, nonatomic) NSNumber * all;

@property (strong, nonatomic) NSNumber * min; // Only for totals
@property (strong, nonatomic) NSNumber * max; // Only for totals

@end
