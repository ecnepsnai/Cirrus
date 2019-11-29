#import <Foundation/Foundation.h>

@interface CFAnalyticThreatsView : NSObject

+ (id) viewWithTotal:(id)total timeSeries:(NSArray *)timeSeries;
@property (strong, nonatomic) CFAnalyticThreatsObject * total;
@property (strong, nonatomic) NSArray<CFAnalyticTimeseries *> * timeseries;

@end
