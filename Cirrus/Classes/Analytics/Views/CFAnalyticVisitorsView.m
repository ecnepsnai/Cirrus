#import "CFAnalyticVisitorsView.h"
@import Charts;

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
