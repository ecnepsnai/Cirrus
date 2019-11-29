#import "CFAnalyticObject.h"

@interface CFAnalyticRequestsObject : CFAnalyticObject

@property (strong, nonatomic) NSNumber * all;
@property (strong, nonatomic) NSNumber * encrypted;
@property (strong, nonatomic) NSNumber * unencrypted;
@property (strong, nonatomic) NSNumber * cached;
@property (strong, nonatomic) NSNumber * uncached;

@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> * country;
@property (strong, nonatomic) NSArray<NSArray<id> *> * top3Countries;

@property (strong, nonatomic) NSNumber * min; // Only for totals
@property (strong, nonatomic) NSNumber * max; // Only for totals

@end
