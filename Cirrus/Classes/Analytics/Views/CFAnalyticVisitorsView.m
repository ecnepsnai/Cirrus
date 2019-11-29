#import "CFAnalyticVisitorsView.h"

@implementation CFAnalyticVisitorsView

+ (id) viewWithTotal:(id)total timeSeries:(NSArray *)timeSeries {
    CFAnalyticVisitorsView * view = [CFAnalyticVisitorsView new];
    view.total = total;
    view.timeseries = timeSeries;
    return view;
}

- (BOOL) showStatView {
    return YES;
}

- (NSString *) statViewTitleForIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return l(@"Total");
        case 1:
            return l(@"Maximum");
        case 2:
            return l(@"Minimum");
        default:
            return nil;
    }
}

- (NSString *) statViewAmountForIndex:(NSUInteger)index {
    switch (index) {
        case 0: {
            return [self.total.all stringValue];
        } case 1:
            return [self.total.max stringValue];
        case 2:
            return [self.total.min stringValue];
        default:
            return nil;
    }
}

- (NSUInteger) numberOfPlotsForGraph {
    return 1;
}

- (NSString *) plotTitleForIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return @"Visitors";
        default:
            return nil;
    }
}

- (UIColor *) colorForPlotIndex:(NSUInteger)index {
    return [UIColor materialBlue];
}

- (CFAnalyticObject *) getObject {
    return self.total;
}

- (NSNumber *) getMaxValue {
    unsigned long long max = 0;
    for (CFAnalyticTimeseries * object in self.timeseries) {
        unsigned long long tsMax = [object.visitors.all unsignedLongLongValue];
        if (tsMax > max) {
            max = tsMax;
        }
    }
    
    return [NSNumber numberWithUnsignedLongLong:max];
}

- (NSNumber *) getMinValue {
    return self.total.min;
}

@end
