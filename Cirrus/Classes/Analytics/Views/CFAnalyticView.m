#import "CFAnalyticView.h"

@implementation CFAnalyticView

+ (id) viewWithTotal:(id)total timeSeries:(NSArray *)timeSeries {
    return nil;
}

- (BOOL) showStatView {
    return NO;
}

- (NSString *) statViewTitleForIndex:(NSUInteger)index {
    return nil;
}

- (NSString *) statViewAmountForIndex:(NSUInteger)index {
    return nil;
}

- (NSUInteger) numberOfPlotsForGraph {
    return 0;
}

- (NSString *) plotTitleForIndex:(NSUInteger)index {
    return nil;
}

- (id) getObject {
    return nil;
}

- (NSNumber *) getMaxValue {
    return nil;
}

- (NSNumber *) getMinValue {
    return nil;
}

- (UIColor *) colorForPlotIndex:(NSUInteger)index {
    return nil;
}

@end
