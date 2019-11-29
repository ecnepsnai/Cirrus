#import "CFAnalyticView.h"

@interface CFDNSAnalyticView : CFAnalyticView

+ (CFDNSAnalyticView *) viewWithResults:(CFDNSAnalyticsResults *)results;

@property (strong, nonatomic) CFDNSAnalyticsResults * results;

- (BOOL) showStatView;
- (NSString *) statViewTitleForIndex:(NSUInteger)index;
- (NSString *) statViewAmountForIndex:(NSUInteger)index;

@end
