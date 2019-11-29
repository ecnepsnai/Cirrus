#import <Foundation/Foundation.h>

@interface CFAnalyticVisitorsView : NSObject

+ (id) viewWithTotal:(id)total timeSeries:(NSArray *)timeSeries;
@property (strong, nonatomic) CFAnalyticVisitorsObject * total;
@property (strong, nonatomic) NSArray<CFAnalyticTimeseries *> * timeseries;

@end
