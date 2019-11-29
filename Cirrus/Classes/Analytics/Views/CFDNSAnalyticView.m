#import "CFDNSAnalyticView.h"
@import Charts;

@implementation CFDNSAnalyticView

+ (id) viewWithTotal:(id)total timeSeries:(NSArray *)timeSeries {
    NSAssert(NO, @"Don't use this method, use [CFDNSAnalyticView viewWithResults:] instead");
    return nil;
}

+ (CFDNSAnalyticView *) viewWithResults:(CFDNSAnalyticsResults *)results {
    CFDNSAnalyticView * view = [CFDNSAnalyticView new];
    view.results = results;
    return view;
}

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

- (void) buildGraphInView:(UIView *)view {
    LineChartView * chart = [[LineChartView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    
    NSMutableArray<ChartDataEntry *> * noerrorEntries = [NSMutableArray new];
    NSMutableArray<ChartDataEntry *> * nxdomainEntries = [NSMutableArray new];
    double x = 0;
    for (CFDNSAnalyticsTimeseries * timeseries in self.results.timeseries) {
        [noerrorEntries addObject:[[ChartDataEntry alloc] initWithX:x y:[timeseries.noerrorCount doubleValue]]];
        [nxdomainEntries addObject:[[ChartDataEntry alloc] initWithX:x y:[timeseries.nxdomainCount doubleValue]]];
        x++;
    }
    
    LineChartDataSet * noerrorLine = [[LineChartDataSet alloc] initWithEntries:noerrorEntries label:l(@"NOERROR")];
    noerrorLine.colors = @[UIColor.materialBlue];
    noerrorLine.mode = LineChartModeCubicBezier;
    noerrorLine.drawCirclesEnabled = NO;
    noerrorLine.drawValuesEnabled = NO;
    noerrorLine.drawFilledEnabled = YES;
    noerrorLine.fillColor = UIColor.materialBlue;
    LineChartDataSet * nxdomainLine = [[LineChartDataSet alloc] initWithEntries:nxdomainEntries label:l(@"NXDOMAIN")];
    nxdomainLine.colors = @[UIColor.materialRed];
    nxdomainLine.mode = LineChartModeCubicBezier;
    nxdomainLine.drawCirclesEnabled = NO;
    nxdomainLine.drawValuesEnabled = NO;
    nxdomainLine.drawFilledEnabled = YES;
    nxdomainLine.fillColor = UIColor.materialRed;
    
    LineChartData * chartData = [LineChartData new];
    [chartData addDataSet:noerrorLine];
    [chartData addDataSet:nxdomainLine];
    
    chart.data = chartData;
    
    [view addSubview:chart];
}

@end
