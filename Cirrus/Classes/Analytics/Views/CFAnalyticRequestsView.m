#import "CFAnalyticRequestsView.h"

@implementation CFAnalyticRequestsView

+ (id) viewWithTotal:(id)total timeSeries:(NSArray *)timeSeries {
    CFAnalyticRequestsView * view = [CFAnalyticRequestsView new];
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
            return l(@"Cached");
        case 2:
            return l(@"Uncached");
        default:
            return nil;
    }
}

- (NSString *) statViewAmountForIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return [self.total.all stringValue];
        case 1:
            return [self.total.cached stringValue];
        case 2:
            return [self.total.uncached stringValue];
        default:
            return nil;
    }
}

- (NSUInteger) numberOfPlotsForGraph {
    return 2;
}

- (NSString *) plotTitleForIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return @"Cached";
        case 1:
            return @"Uncached";
        default:
            return nil;
    }
}

- (UIColor *) colorForPlotIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return [UIColor materialOrange];
        case 1:
            return [UIColor materialBlue];
        default:
            return nil;
    }
}

- (CFAnalyticObject *) getObject {
    return self.total;
}

- (NSNumber *) getMaxValue {
    unsigned long long (^selectLargest)(NSNumber *, NSNumber *) = ^(NSNumber * p1, NSNumber * p2) {
        unsigned long long ul1 = [p1 unsignedLongLongValue];
        unsigned long long ul2 = [p2 unsignedLongLongValue];
        return ul1 > ul2 ? ul1 : ul2;
    };
    
    unsigned long long max = 0;
    for (CFAnalyticTimeseries * object in self.timeseries) {
        unsigned long long tsMax = selectLargest(object.requests.cached, object.requests.uncached);
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
