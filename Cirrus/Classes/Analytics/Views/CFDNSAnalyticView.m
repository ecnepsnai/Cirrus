#import "CFDNSAnalyticView.h"

@implementation CFDNSAnalyticView

- (BOOL) showStatView {
    return YES;
}

- (NSString *) statViewTitleForIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return l(@"DNS Queries");
        case 1:
            return l(@"DNS Errors");
    }

    return nil;
}

- (NSString *) statViewAmountForIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return [self.results.total stringValue];
        case 1:
            return [self.results.totalError stringValue];
    }

    return nil;
}

- (NSUInteger) numberOfPlotsForGraph {
    return self.results.hasErrorResponse ? 2 : 1;
}

- (NSString *) plotTitleForIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return @"NOERROR";
        case 1:
            return @"NXDOMAIN";
    }

    return nil;
}

- (UIColor *) colorForPlotIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return [UIColor materialBlue];
        case 1:
            return [UIColor materialOrange];
        default:
            return nil;
    }
}

@end
