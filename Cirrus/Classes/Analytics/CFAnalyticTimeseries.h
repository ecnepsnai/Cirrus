#import <Foundation/Foundation.h>

#import "CFAnalyticRequestsObject.h"
#import "CFAnalyticVisitorsObject.h"
#import "CFAnalyticBandwidthObject.h"
#import "CFAnalyticThreatsObject.h"

@interface CFAnalyticTimeseries : NSObject

@property (strong, nonatomic) NSDate * startDate;
@property (strong, nonatomic) NSDate * endDate;
@property (strong, nonatomic) CFAnalyticRequestsObject * requests;
@property (strong, nonatomic) CFAnalyticVisitorsObject * visitors;
@property (strong, nonatomic) CFAnalyticBandwidthObject * bandwidth;
@property (strong, nonatomic) CFAnalyticThreatsObject * threats;

+ (CFAnalyticTimeseries *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;

@end
