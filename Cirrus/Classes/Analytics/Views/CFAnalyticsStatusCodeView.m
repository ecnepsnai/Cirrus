#import "CFAnalyticsStatusCodeView.h"

@implementation CFAnalyticsStatusCodeView

+ (id) viewWithTotal:(id)total timeSeries:(NSArray *)timeSeries {
    CFAnalyticsStatusCodeView * view = [CFAnalyticsStatusCodeView new];
    view.total = total;
    view.timeseries = timeSeries;
    return view;
}

- (BOOL) showStatView {
    return NO;
}

- (CFAnalyticObject *) getObject {
    return self.total;
}

- (void) buildGraphInView:(UIView *)view {
    LineChartView * chart = [[LineChartView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    
    NSMutableArray<ChartDataEntry *> * visitorEntries = [NSMutableArray new];
    double x = 0;
    for (CFAnalyticTimeseries * object in self.timeseries) {
        [visitorEntries addObject:[[ChartDataEntry alloc] initWithX:x y:[object.visitors.all doubleValue]]];
        x++;
    }
    
    LineChartDataSet * visitorLine = [[LineChartDataSet alloc] initWithEntries:visitorEntries label:l(@"Visitors")];
    visitorLine.colors = @[UIColor.materialBlue];
    visitorLine.drawCirclesEnabled = NO;
    visitorLine.drawValuesEnabled = NO;
    
    LineChartData * chartData = [LineChartData new];
    [chartData addDataSet:visitorLine];
    
    chart.data = chartData;
    
    [view addSubview:chart];
}

@end
