#import "CFAnalyticRequestsView.h"
@import Charts;

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

- (CFAnalyticObject *) getObject {
    return self.total;
}

- (void) buildGraphInView:(UIView *)view {
    LineChartView * chart = [[LineChartView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    
    NSMutableArray<ChartDataEntry *> * cachedEntries = [NSMutableArray new];
    NSMutableArray<ChartDataEntry *> * uncachedEntries = [NSMutableArray new];
    double x = 0;
    for (CFAnalyticTimeseries * object in self.timeseries) {
        [cachedEntries addObject:[[ChartDataEntry alloc] initWithX:x y:[object.requests.cached doubleValue]]];
        [uncachedEntries addObject:[[ChartDataEntry alloc] initWithX:x y:[object.requests.uncached doubleValue]]];
        x++;
    }
    
    LineChartDataSet * cachedLine = [[LineChartDataSet alloc] initWithEntries:cachedEntries label:l(@"Cached")];
    cachedLine.colors = @[UIColor.materialBlue];
    cachedLine.mode = LineChartModeCubicBezier;
    cachedLine.drawCirclesEnabled = NO;
    cachedLine.drawValuesEnabled = NO;
    cachedLine.drawFilledEnabled = YES;
    cachedLine.fillColor = UIColor.materialBlue;
    LineChartDataSet * uncachedLine = [[LineChartDataSet alloc] initWithEntries:uncachedEntries label:l(@"Unached")];
    uncachedLine.colors = @[UIColor.materialRed];
    uncachedLine.mode = LineChartModeCubicBezier;
    uncachedLine.drawCirclesEnabled = NO;
    uncachedLine.drawValuesEnabled = NO;
    uncachedLine.drawFilledEnabled = YES;
    uncachedLine.fillColor = UIColor.materialRed;
    
    LineChartData * chartData = [LineChartData new];
    [chartData addDataSet:cachedLine];
    [chartData addDataSet:uncachedLine];
    
    chart.data = chartData;
    
    [view addSubview:chart];
}

@end
