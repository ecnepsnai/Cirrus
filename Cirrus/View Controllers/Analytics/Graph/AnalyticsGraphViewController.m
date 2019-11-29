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

@interface AnalyticsGraphViewController () {
    BOOL collapseViewType;
    NSInteger selectedViewSegment;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *viewType;
@property (weak, nonatomic) IBOutlet UIStackView *statViewsStack;
@property (strong, nonatomic) NSArray<CFAnalyticView *> * analyticsViews;
@property (strong, nonatomic) CFAnalyticsResults * data;
@property (strong, nonatomic) OCSelector * dataSelector;
@property (strong, nonatomic) OCSelector * loadSelector;
@property (nonatomic) CFAnalyticsTimeframe currentTimeframe;

@end

@implementation AnalyticsGraphViewController

#define currentAnalytic [self.analyticsViews objectAtIndex:[self.viewType selectedSegmentIndex]]

typedef NS_ENUM(NSUInteger, AnalyticsViewType) {
    AnalyticsViewTypeRequests = 0,
    AnalyticsViewTypeBandwidth = 1,
    AnalyticsViewTypeVisitors = 2,
    AnalyticsViewTypeThreats = 3,
    AnalyticsViewTypeRateLimiting = 4
};

- (void) viewDidLoad {
    [super viewDidLoad];

    self.currentTimeframe = CFAnalyticsTimeframe24Hours;
    
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

- (void) loadData {
    self.viewType.enabled = NO;
}

- (IBAction) changeTime:(UIBarButtonItem *)sender {
    NSArray<NSString *> * choices = @[
                                      l(@"Last 24 Hours"),
                                      l(@"Last Week"),
                                      l(@"Last Month")
                                      ];
    [uihelper
     presentActionSheetInViewController:self
     attachToTarget:[ActionTipTarget targetWithBarButtonItem:sender]
     title:l(@"Select Timeframe")
     subtitle:nil
     cancelButtonTitle:l(@"Cancel")
     items:choices
     dismissed:^(NSInteger itemIndex) {
         if (itemIndex != -1) {
             self.currentTimeframe = itemIndex;
             [self loadData];
         }
     }];
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
    switch (self.currentTimeframe) {
        case CFAnalyticsTimeframe6Hours:
            view.timeframeLabel.text = l(@"6 hours");
            break;
        case CFAnalyticsTimeframe12Hours:
            view.timeframeLabel.text = l(@"12 hours");
            break;
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
    if ([currentAnalytic showStatView]) {
        self.statViewsStack.hidden = NO;
        nTimes(3) {
            [self buildStatViewAtIndex:i];
        }
    } else {
        self.statViewsStack.hidden = YES;
    }
}

@end
