#import "CFAnalyticView.h"

@interface CFDNSAnalyticView : CFAnalyticView

@property (strong, nonatomic) CFDNSAnalyticsResults * results;

- (BOOL) showStatView;
- (NSString *) statViewTitleForIndex:(NSUInteger)index;
- (NSString *) statViewAmountForIndex:(NSUInteger)index;
- (NSUInteger) numberOfPlotsForGraph;
- (NSString *) plotTitleForIndex:(NSUInteger)index;
- (UIColor *) colorForPlotIndex:(NSUInteger)index;

@end
