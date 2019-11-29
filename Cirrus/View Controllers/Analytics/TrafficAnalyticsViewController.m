#import "TrafficAnalyticsViewController.h"
#import "CFAnalyticView.h"
#import "CFAnalyticRequestsView.h"
#import "CFAnalyticVisitorsView.h"
#import "CFAnalyticBandwidthView.h"
#import "AnalyticsStatView.h"

@interface TrafficAnalyticsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl * typeSegment;
@property (weak, nonatomic) IBOutlet UIStackView * analyticsStackView;
@property (weak, nonatomic) IBOutlet UIView * graphView;
@property (nonatomic) CFAnalyticsTimeframe currentTimeframe;
@property (strong, nonatomic) NSArray<CFAnalyticView *> * analyticsViews;

@end

@implementation TrafficAnalyticsViewController

#define currentAnalytic [self.analyticsViews objectAtIndex:[self.typeSegment selectedSegmentIndex]]

typedef NS_ENUM(NSUInteger, AnalyticsViewType) {
    AnalyticsViewTypeRequests = 0,
    AnalyticsViewTypeBandwidth = 1,
    AnalyticsViewTypeVisitors = 2,
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentTimeframe = CFAnalyticsTimeframe24Hours;
    self.analyticsViews = @[
    [CFAnalyticRequestsView new],
    [CFAnalyticVisitorsView new],
    [CFAnalyticBandwidthView new]
    ];
    
    [self loadData];
}

- (void) viewDidLayoutSubviews {
    [self buildChart];
}

- (IBAction) timeframeButton:(id)sender {
    NSArray<NSString *> * choices = @[
                                      l(@"Last 6 Hours"),
                                      l(@"Last 12 Hours"),
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
             self.navigationItem.prompt = choices[itemIndex];
             [self loadData];
         }
     }];
}

- (IBAction)typeSegmentChange:(id)sender {
    [self loadDataForViewType:self.typeSegment.selectedSegmentIndex];
    [self buildChart];
}

- (void) loadData {
    [self showProgressControl];
    [api analyticsForZone:currentZone timeframe:self.currentTimeframe finished:^(CFAnalyticsResults *results, NSError *error) {
        [self hideProgressControl];
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [uihelper presentErrorInViewController:self error:error dismissed:nil];
            });
            return;
        }
        
        self.analyticsViews = @[
        [CFAnalyticRequestsView viewWithTotal:results.totals.requests timeSeries:results.timeseries],
        [CFAnalyticBandwidthView viewWithTotal:results.totals.bandwidth timeSeries:results.timeseries],
        [CFAnalyticVisitorsView viewWithTotal:results.totals.visitors timeSeries:results.timeseries],
        ];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadDataForViewType:self.typeSegment.selectedSegmentIndex];
            [self buildChart];
        });
    }];
}

- (void) buildStatViewAtIndex:(NSUInteger)index {
    AnalyticsStatView * view = (AnalyticsStatView *)[self.analyticsStackView.subviews objectAtIndex:index];
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
        self.analyticsStackView.hidden = NO;
        nTimes(3) {
            [self buildStatViewAtIndex:i];
        }
    } else {
        self.analyticsStackView.hidden = YES;
    }
}

- (void) buildChart {
    for (UIView * subview in self.graphView.subviews) {
        [subview removeFromSuperview];
    }
    [currentAnalytic buildGraphInView:self.graphView];
}

@end
