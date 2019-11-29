#import "AnalyticsGraphViewController.h"
#import "AnalyticsStatView.h"

#import "CFAnalyticObject.h"
#import "CFAnalyticRequestsObject.h"
#import "CFAnalyticVisitorsObject.h"
#import "CFAnalyticBandwidthObject.h"
#import "CFAnalyticThreatsObject.h"

#import "CFAnalyticView.h"
#import "CFAnalyticRequestsView.h"
#import "CFAnalyticVisitorsView.h"
#import "CFAnalyticBandwidthView.h"
#import "CFAnalyticThreatsView.h"

@import CorePlot;

@interface AnalyticsGraphViewController () <CPTPlotDataSource, CPTPlotSpaceDelegate> {
    BOOL collapseViewType;
    NSInteger selectedViewSegment;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *viewType;
@property (weak, nonatomic) IBOutlet UIStackView *statViewsStack;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphHost;
@property (strong, nonatomic) NSArray<CFAnalyticView *> * analyticsViews;
@property (strong, nonatomic) CPTGraph * graph;
@property (strong, nonatomic) NSMutableArray<CPTScatterPlot *> * plots;
@property (strong, nonatomic) CFAnalyticsResults * data;
@property (strong, nonatomic) OCSelector * dataSelector;
@property (strong, nonatomic) OCSelector * loadSelector;

@end

@implementation AnalyticsGraphViewController

#define currentAnalytic [self.analyticsViews objectAtIndex:(collapseViewType ? selectedViewSegment : [self.viewType selectedSegmentIndex])]

typedef NS_ENUM(NSUInteger, AnalyticsViewType) {
    AnalyticsViewTypeRequests = 0,
    AnalyticsViewTypeBandwidth = 1,
    AnalyticsViewTypeVisitors = 2,
    AnalyticsViewTypeThreats = 3,
    AnalyticsViewTypeRateLimiting = 4
};

- (void) viewDidLoad {
    [super viewDidLoad];

    self.plots = [NSMutableArray new];

    self.analyticsViews = @[
                            [CFAnalyticRequestsView new],
                            [CFAnalyticVisitorsView new],
                            [CFAnalyticBandwidthView new],
                            [CFAnalyticThreatsView new]
                            ];

    self.dataSelector = [OCSelector selectorWithTarget:self action:@selector(didRecieveData:)];
    self.loadSelector = [OCSelector selectorWithTarget:self action:@selector(loadData)];

    [self loadDataForViewType:AnalyticsViewTypeRequests];
}

- (void) setParent:(AnalyticsViewController *)parent {
    _parent = parent;
    [parent setDataObservationsWithRecievedData:self.dataSelector loadStarted:self.loadSelector];
}

- (void) loadData {
    self.viewType.enabled = NO;
}

- (void) didRecieveData:(CFAnalyticsResults *)results {
    self.data = results;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.viewType.enabled = YES;
        self.analyticsViews = @[
                                [CFAnalyticRequestsView viewWithTotal:results.totals.requests timeSeries:results.timeseries],
                                [CFAnalyticBandwidthView viewWithTotal:results.totals.bandwidth timeSeries:results.timeseries],
                                [CFAnalyticVisitorsView viewWithTotal:results.totals.visitors timeSeries:results.timeseries],
                                [CFAnalyticThreatsView viewWithTotal:results.totals.threats timeSeries:results.timeseries]
                                ];
        [self loadDataForViewType:self.viewType.selectedSegmentIndex];
    });
}

- (void) viewDidLayoutSubviews {
    if (self.graph) {
        [self positionLegend];
    }

    CGFloat width = self.view.frame.size.width;
    // Width of a iPhone 6, 6s, 7 (non plus) in portrait orientation.
    CGFloat IPHONE_47_INCH_WIDTH = 375.0f;
    if (width <= IPHONE_47_INCH_WIDTH) {
        if (!collapseViewType && self.viewType.numberOfSegments > 4) {
            [self.viewType setTitle:l(@"More") forSegmentAtIndex:3];
            [self.viewType removeSegmentAtIndex:4 animated:NO];
            collapseViewType = YES;
        }
    } else {
        collapseViewType = NO;
        if (self.viewType.numberOfSegments != 4) {
            [self.viewType setTitle:l(@"Threats") forSegmentAtIndex:3];
            [self.viewType insertSegmentWithTitle:l(@"Rate Limits") atIndex:4 animated:NO];
        }
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) viewChanged:(UISegmentedControl *)sender {
    if (collapseViewType) {
        if (sender.selectedSegmentIndex < 3) {
            selectedViewSegment = sender.selectedSegmentIndex;
            [self logViewTypeChange];
            [self loadDataForViewType:selectedViewSegment];
        } else {
            [uihelper
             presentActionSheetInViewController:self
             attachToTarget:[ActionTipTarget targetWithView:sender]
             title:l(@"Analytics View")
             subtitle:nil
             cancelButtonTitle:l(@"Cancel")
             items:@[
                     l(@"Threats"),
                     l(@"Rate Limits")
                     ]
             dismissed:^(NSInteger itemIndex) {
                 if (itemIndex != -1) {
                     self->selectedViewSegment = itemIndex + 3; // Offset by the fixed number of segments
                     [self logViewTypeChange];
                     [self loadDataForViewType:self->selectedViewSegment];
                 }
             }];
        }
    } else {
        [self logViewTypeChange];
        [self loadDataForViewType:selectedViewSegment];
    }
}

- (void) logViewTypeChange {
    NSString * viewTypeName;
    switch (selectedViewSegment) {
        case AnalyticsViewTypeRequests:
            viewTypeName = @"Requests";
            break;
        case AnalyticsViewTypeBandwidth:
            viewTypeName = @"Bandwidth";
            break;
        case AnalyticsViewTypeVisitors:
            viewTypeName = @"Visitors";
            break;
        case AnalyticsViewTypeThreats:
            viewTypeName = @"Threats";
            break;
        case AnalyticsViewTypeRateLimiting:
            viewTypeName = @"Rate Limiting";
            break;
        default:
            viewTypeName = @"Unknown";
            break;
    }
}

- (void) buildStatViewAtIndex:(NSUInteger)index {
    AnalyticsStatView * view = (AnalyticsStatView *)[self.statViewsStack.subviews objectAtIndex:index];
    view.typeLabel.text = [currentAnalytic statViewTitleForIndex:index];
    switch (self.parent.currentTimeframe) {
        case CFAnalyticsTimeframe24Hours:
            view.timeframeLabel.text = l(@"24 hours");
            break;
        case CFAnalyticsTimeframeLastWeek:
            view.timeframeLabel.text = l(@"1 week");
            break;
        case CFAnalyticsTimeframeLastMonth:
            view.timeframeLabel.text = l(@"1 month");
            break;
    }
    view.valueLabel.text = [currentAnalytic statViewAmountForIndex:index];
}

- (void) loadDataForViewType:(AnalyticsViewType)type {
    if (self.data) {
        [self buildChart];
    }

    if ([currentAnalytic showStatView]) {
        self.statViewsStack.hidden = NO;
        nTimes(3) {
            [self buildStatViewAtIndex:i];
        }
    } else {
        self.statViewsStack.hidden = YES;
    }
}

- (void) buildChart {
    self.graph = nil;

    self.graph = [[CPTXYGraph alloc] initWithFrame:self.graphHost.bounds];
    self.graphHost.hostedGraph = self.graph;

    CPTXYPlotSpace * plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromFloat(0.0)
                                                    lengthDecimal:CPTDecimalFromFloat(1.0)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocationDecimal:CPTDecimalFromInt(0)
                                                    lengthDecimal:CPTDecimalFromUnsignedLong((unsigned int)self.data.timeseries.count)];

    CPTXYAxisSet * axisSet = (CPTXYAxisSet *)self.graph.axisSet;

    { // X Axis
        CPTAxis * x = axisSet.xAxis;
        if (self.parent.currentTimeframe == CFAnalyticsTimeframeLastWeek) {
            x.majorIntervalLength = @1;
        } else {
            x.majorIntervalLength = @6;
        }
        CPTMutableLineStyle * style = [CPTMutableLineStyle lineStyle];
        style.lineWidth = 0.5f;
        style.lineFill = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
        x.majorTickLineStyle = style;
        x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
        switch (self.parent.currentTimeframe) {
            case CFAnalyticsTimeframe24Hours:
                x.labelFormatter = [OCHourNumberFormatter new];
                break;
            case CFAnalyticsTimeframeLastWeek:
                x.labelFormatter = [OCWeekNumberFormatter new];
                break;
            case CFAnalyticsTimeframeLastMonth:
                x.labelFormatter = [OCMonthNumberFormatter new];
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
        OCNumberFormatter * formatter;
        switch (self.viewType.selectedSegmentIndex) {
            case AnalyticsViewTypeRequests: {
                formatter = [OCCountNumberFormatter new];
                break;
            } case AnalyticsViewTypeBandwidth: {
                formatter = [OCBandwidthNumberFormatter new];
                break;
            } case AnalyticsViewTypeVisitors: {
                formatter = [OCCountNumberFormatter new];
                break;
            } case AnalyticsViewTypeThreats: {
                formatter = [OCCountNumberFormatter new];
                break;
            }
        }
        formatter.min = [currentAnalytic getMinValue];
        formatter.max = [currentAnalytic getMaxValue];
        y.labelFormatter = formatter;
    }


    NSUInteger numberOfPlots = [currentAnalytic numberOfPlotsForGraph];

    nTimes(numberOfPlots) {
        CPTScatterPlot * plot = [CPTScatterPlot new];

        CPTMutableLineStyle * lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.lineWidth = 1.0f;

        UIColor * plotColor = [currentAnalytic colorForPlotIndex:i];
        lineStyle.lineColor = [CPTColor colorWithCGColor:plotColor.CGColor];
        plot.areaFill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:[plotColor colorWithAlphaComponent:0.15].CGColor]];
        plot.areaBaseValue = @0;
        plot.zPosition = (float)i;

        plot.dataSource = self;
        plot.title = [currentAnalytic plotTitleForIndex:i];
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
            self.graph.legend.numberOfColumns = [currentAnalytic numberOfPlotsForGraph];
            self.graph.legend.numberOfRows = 1;
        } else {
            self.graph.legendAnchor = CPTRectAnchorLeft;
            self.graph.paddingLeft = 120.0f;
            self.graph.paddingBottom = 0.0f;
            self.graph.legend.numberOfRows = [currentAnalytic numberOfPlotsForGraph];
            self.graph.legend.numberOfColumns = 1;
        }
    } else {
        self.graph.legendAnchor = CPTRectAnchorBottom;
        self.graph.paddingBottom = 60.0f;
        self.graph.paddingLeft = 0.0f;
        self.graph.legend.numberOfColumns = [currentAnalytic numberOfPlotsForGraph];
        self.graph.legend.numberOfRows = 1;
    }
}

- (NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.data.timeseries.count;
}

- (id) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    if (fieldEnum == CPTScatterPlotFieldX) {
        return [NSNumber numberWithUnsignedInteger:idx];
    }

    CFAnalyticTimeseries * timeseries = self.data.timeseries[idx];
    NSNumber * val;
    switch (self.viewType.selectedSegmentIndex) {
        case AnalyticsViewTypeRequests: {
            if ([plot.identifier isEqual:@0]) {
                val = timeseries.requests.cached;
            } else if ([plot.identifier isEqual:@1]) {
                val = timeseries.requests.uncached;
            }
            break;
        } case AnalyticsViewTypeBandwidth: {
            if ([plot.identifier isEqual:@0]) {
                val = timeseries.bandwidth.cached;
            } else if ([plot.identifier isEqual:@1]) {
                val = timeseries.bandwidth.uncached;
            }
            break;
        } case AnalyticsViewTypeVisitors: {
            val = timeseries.visitors.all;
            break;
        } case AnalyticsViewTypeThreats: {
            val = timeseries.threats.all;
            break;
        }
    }

    if (!val) {
        return @0;
    }

    if ([val isEqualToNumber:@0]) {
        return @0;
    }

    return [NSNumber numberWithDouble:(float)[val unsignedLongLongValue] / (float)[[currentAnalytic getMaxValue] unsignedIntValue]];
}

@end
