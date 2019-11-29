#import <UIKit/UIKit.h>
#import "CFAnalyticsStatusCodeObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CFAnalyticsStatusCodeView : NSObject

+ (id) viewWithTotal:(id)total timeSeries:(NSArray *)timeSeries;
@property (strong, nonatomic) CFAnalyticsStatusCodeObject * total;
@property (strong, nonatomic) NSArray<CFAnalyticTimeseries *> * timeseries;

@end

NS_ASSUME_NONNULL_END
