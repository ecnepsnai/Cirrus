#import <Foundation/Foundation.h>

@interface CFAnalyticRequestsView : NSObject

+ (id) viewWithTotal:(id)total timeSeries:(NSArray *)timeSeries;
@property (strong, nonatomic) CFAnalyticRequestsObject * total;
@property (strong, nonatomic) NSArray<CFAnalyticTimeseries *> * timeseries;

@end
