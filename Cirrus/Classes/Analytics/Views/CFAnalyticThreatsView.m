#import "CFAnalyticThreatsView.h"

@implementation CFAnalyticThreatsView

+ (id) viewWithTotal:(id)total timeSeries:(NSArray *)timeSeries {
    CFAnalyticThreatsView * view = [CFAnalyticThreatsView new];
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
            return l(@"Top Country");
        case 2:
            return l(@"Top Type");
        default:
            return nil;
    }
}

- (NSString *) statViewAmountForIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return [self.total.all stringValue];
        case 1: {
            if (self.total.country.count > 0) {
                return l(format(@"Country::%@", [[self.total.country allKeys] objectAtIndex:0]));
            } else {
                return @"N/A";
            }
        } case 2: {
            if (self.total.type.count > 0) {
                return l(format(@"CFAPI::threats::%@", [[self.total.type allKeys] objectAtIndex:0]));
            } else {
                return @"N/A";
            }
        } default:
            return nil;
    }
}

- (NSUInteger) numberOfPlotsForGraph {
    return 1;
}

- (NSString *) plotTitleForIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return @"Threats";
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
        unsigned long long tsMax = [object.threats.all unsignedLongLongValue];
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
