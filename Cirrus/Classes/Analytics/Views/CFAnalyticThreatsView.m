#import "CFAnalyticThreatsView.h"
@import Charts;

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

- (CFAnalyticObject *) getObject {
    return self.total;
}

- (void) buildGraphInView:(UIView *)view {
    LineChartView * chart = [[LineChartView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    
    NSMutableArray<ChartDataEntry *> * threatEntries = [NSMutableArray new];
    double x = 0;
    for (CFAnalyticTimeseries * object in self.timeseries) {
        [threatEntries addObject:[[ChartDataEntry alloc] initWithX:x y:[object.threats.all doubleValue]]];
        x++;
    }
    
    LineChartDataSet * threatLine = [[LineChartDataSet alloc] initWithEntries:threatEntries label:l(@"Threats")];
    threatLine.colors = @[UIColor.materialRed];
    threatLine.drawCirclesEnabled = NO;
    threatLine.drawValuesEnabled = NO;
    
    LineChartData * chartData = [LineChartData new];
    [chartData addDataSet:threatLine];
    
    chart.data = chartData;
    
    [view addSubview:chart];
}

@end
