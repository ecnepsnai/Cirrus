#import <Foundation/Foundation.h>

@interface CFAnalyticView : NSObject

+ (id) viewWithTotal:(id)total timeSeries:(NSArray *)timeSeries;
- (CFAnalyticObject *) getObject;
- (NSNumber *) getMaxValue;
- (NSNumber *) getMinValue;
- (BOOL) showStatView;
- (NSString *) statViewTitleForIndex:(NSUInteger)index;
- (NSString *) statViewAmountForIndex:(NSUInteger)index;
- (NSUInteger) numberOfPlotsForGraph;
- (NSString *) plotTitleForIndex:(NSUInteger)index;
- (UIColor *) colorForPlotIndex:(NSUInteger)index;

@end
