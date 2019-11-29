#import <Foundation/Foundation.h>

@interface CFAnalyticBandwidthView : NSObject

+ (id) viewWithTotal:(id)total timeSeries:(NSArray *)timeSeries;
@property (strong, nonatomic) CFAnalyticBandwidthObject * total;
@property (strong, nonatomic) NSArray<CFAnalyticTimeseries *> * timeseries;

@end
