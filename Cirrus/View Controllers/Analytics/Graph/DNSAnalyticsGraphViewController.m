#import "DNSAnalyticsGraphViewController.h"
#import "CFDNSAnalyticView.h"
#import "AnalyticsStatView.h"

@interface DNSAnalyticsGraphViewController () <CPTPlotDelegate, CPTPlotSpaceDelegate, CPTPlotDataSource>

@property (weak, nonatomic) IBOutlet UIStackView *statViewsStack;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphHost;
@property (strong, nonatomic) CPTGraph * graph;
@property (strong, nonatomic) NSMutableArray<CPTScatterPlot *> * plots;
@property (strong, nonatomic) OCSelector * dataSelector;
@property (strong, nonatomic) OCSelector * loadSelector;
@property (strong, nonatomic) CFDNSAnalyticView * analyticView;

@end

@implementation DNSAnalyticsGraphViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    self.plots = [NSMutableArray new];

    self.dataSelector = [OCSelector selectorWithTarget:self action:@selector(didRecieveData:)];
    self.loadSelector = [OCSelector selectorWithTarget:self action:@selector(loadData)];
    self.statViewsStack.hidden = YES;
    [self changeTimeframe];
    subscribe(@selector(changeTimeframe), NOTIF_DNS_TIMEFRAME_CHANGED);
}

- (void) changeTimeframe {
    [self showProgressControl];

    [api dnsAnalyticsForZone:currentZone timeframe:self.parent.dnsTimeframe finished:^(CFDNSAnalyticsResults *results, NSError *error) {
        [self hideProgressControl];

        if (error) {
            [uihelper presentErrorInViewController:self.parent error:error dismissed:nil];
        } else {
            self.analyticView = [CFDNSAnalyticView new];
            self.analyticView.results = results;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statViewsStack.hidden = NO;
                [self buildChart];
                nTimes(2) {
                    [self buildStatViewAtIndex:i];
                }
            });
        }
    }];
}

- (void) setParent:(AnalyticsViewController *)parent {
    _parent = parent;
    [parent setDataObservationsWithRecievedData:self.dataSelector loadStarted:self.loadSelector];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) loadData {
}

- (void) didRecieveData:(CFAnalyticsResults *)results {
}

- (void) buildStatViewAtIndex:(NSUInteger)index {
    AnalyticsStatView * view = (AnalyticsStatView *)[self.statViewsStack.subviews objectAtIndex:index];
    view.typeLabel.text = [self.analyticView statViewTitleForIndex:index];
    view.timeframeLabel.text = self.parent.dnsTimeframe == CFDNSAnalyticsTimeframe6Hours ? l(@"6 hours") : l(@"30 Minutes");
    view.valueLabel.text = [self.analyticView statViewAmountForIndex:index];
}

- (void) buildChart {
    self.graph = nil;

    self.graph = [[CPTXYGraph alloc] initWithFrame:self.graphHost.bounds];
    self.graphHost.hostedGraph = self.graph;

    CPTXYPlotSpace * plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0)
                                                    lengthDecimal:CPTDecimalFromFloat(1.0)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromInt(0)
                                                    lengthDecimal:CPTDecimalFromUnsignedLong((unsigned int)self.analyticView.results.timeseries.count)];

    CPTXYAxisSet * axisSet = (CPTXYAxisSet *)self.graph.axisSet;

    { // X Axis
        CPTAxis * x = axisSet.xAxis;
        CPTMutableLineStyle * style = [CPTMutableLineStyle lineStyle];
        style.lineWidth = 0.5f;
        style.lineFill = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
        x.majorTickLineStyle = style;
        x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
        switch (self.parent.dnsTimeframe) {
            case CFDNSAnalyticsTimeframe30Minutes:
                x.labelFormatter = [OC30MinuteNumberFormatter new];
                x.majorIntervalLength = @1;
                break;
            case CFDNSAnalyticsTimeframe6Hours:
                x.labelFormatter = [OC6HourNumberFormatter new];
                x.majorIntervalLength = @4;
                break;
        }
    }

    { // Y Axis
        CPTAxis * y = axisSet.yAxis;
        y.majorIntervalLength = @0.1;
        y.preferredNumberOfMajorTicks = 10;
        y.minorTicksPerInterval = 1;
        CPTMutableLineStyle * style = [CPTMutableLineStyle lineStyle];
        style.lineWidth = 0.5f;
        style.lineFill = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
        y.majorTickLineStyle = style;
        y.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
        OCNumberFormatter * formatter = [OCCountNumberFormatter new];
        formatter.min = self.analyticView.results.min;
        formatter.max = self.analyticView.results.max;
        y.labelFormatter = formatter;
    }


    NSUInteger numberOfPlots = [self.analyticView numberOfPlotsForGraph];

    nTimes(numberOfPlots) {
        CPTScatterPlot * plot = [CPTScatterPlot new];

        CPTMutableLineStyle * lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.lineWidth = 1.0f;

        UIColor * plotColor = [self.analyticView colorForPlotIndex:i];
        lineStyle.lineColor = [CPTColor colorWithCGColor:plotColor.CGColor];
        plot.areaFill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:[plotColor colorWithAlphaComponent:0.15].CGColor]];
        plot.areaBaseValue = @0;
        plot.zPosition = (float)i;

        plot.dataSource = self;
        plot.title = [self.analyticView plotTitleForIndex:i];
        plot.identifier = [NSNumber numberWithInt:i];
        plot.dataLineStyle = lineStyle;
        [self.graph addPlot:plot];
    }

    self.graph.plotAreaFrame.paddingTop = 5.0f;
    self.graph.plotAreaFrame.paddingRight = 5.0f;
    self.graph.plotAreaFrame.paddingLeft = 45.0f;
    self.graph.plotAreaFrame.paddingBottom = 25.0f;

    self.graph.legend = [CPTLegend legendWithGraph:self.graph];
    self.graph.legend.swatchSize = CGSizeMake(25.0f, 25.0f);
    self.graph.legendDisplacement = CGPointMake(0.0f, 30.0f);
    [self positionLegend];
}

- (void) positionLegend {
    if (isCompact) {
        if (isPortrait) {
            self.graph.legendAnchor = CPTRectAnchorBottom;
            self.graph.paddingBottom = 60.0f;
            self.graph.paddingLeft = 0.0f;
            self.graph.legend.numberOfColumns = [self.analyticView numberOfPlotsForGraph];
            self.graph.legend.numberOfRows = 1;
        } else {
            self.graph.legendAnchor = CPTRectAnchorLeft;
            self.graph.paddingLeft = 120.0f;
            self.graph.paddingBottom = 0.0f;
            self.graph.legend.numberOfRows = [self.analyticView numberOfPlotsForGraph];
            self.graph.legend.numberOfColumns = 1;
        }
    } else {
        self.graph.legendAnchor = CPTRectAnchorBottom;
        self.graph.paddingBottom = 60.0f;
        self.graph.paddingLeft = 0.0f;
        self.graph.legend.numberOfColumns = [self.analyticView numberOfPlotsForGraph];
        self.graph.legend.numberOfRows = 1;
    }
}

- (NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.analyticView.results.timeseries.count;
}

- (id) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    if (fieldEnum == CPTScatterPlotFieldX) {
        return [NSNumber numberWithUnsignedInteger:idx];
    }

    NSNumber * val;
    CFDNSAnalyticsTimeseries * timeseries = [self.analyticView.results.timeseries objectAtIndex:idx];
    if ([plot.identifier isEqual:@0]) {
        val = timeseries.noerrorCount;
    } else if ([plot.identifier isEqual:@1]) {
        val = timeseries.nxdomainCount;
    }

    if (!val) {
        return @0;
    }

    if ([val isEqualToNumber:@0]) {
        return @0;
    }

    return [NSNumber numberWithDouble:(float)[val unsignedLongLongValue] / (float)[self.analyticView.results.max unsignedIntValue]];
}

@end
