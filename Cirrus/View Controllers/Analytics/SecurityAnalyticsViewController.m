#import "SecurityAnalyticsViewController.h"
#import "CFAnalyticView.h"
#import "CFAnalyticThreatsView.h"
#import "AnalyticsStatView.h"

@interface SecurityAnalyticsViewController ()

@property (weak, nonatomic) IBOutlet UIStackView * analyticsStackView;
@property (weak, nonatomic) IBOutlet UIView * graphView;
@property (nonatomic) CFAnalyticsTimeframe currentTimeframe;
@property (strong, nonatomic) CFAnalyticThreatsView * analyticView;

@end

@implementation SecurityAnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentTimeframe = CFAnalyticsTimeframe24Hours;
    self.analyticView = [CFAnalyticThreatsView new];
    
    [self loadData];
}

- (void) viewDidLayoutSubviews {
    [self buildChart];
}

- (IBAction) timeframeButton:(id)sender {
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
             self.navigationItem.prompt = choices[itemIndex];
             [self loadData];
         }
     }];
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
        
        self.analyticView = [CFAnalyticThreatsView viewWithTotal:results.totals.threats timeSeries:results.timeseries];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.analyticsStackView.hidden = NO;
            nTimes(3) {
                [self buildStatViewAtIndex:i];
            }
            [self buildChart];
        });
    }];
}

- (void) buildStatViewAtIndex:(NSUInteger)index {
    AnalyticsStatView * view = (AnalyticsStatView *)[self.analyticsStackView.subviews objectAtIndex:index];
    view.typeLabel.text = [(CFAnalyticView *)self.analyticView statViewTitleForIndex:index];
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
    view.valueLabel.text = [(CFAnalyticView *)self.analyticView statViewAmountForIndex:index];
}

- (void) buildChart {
    for (UIView * subview in self.graphView.subviews) {
        [subview removeFromSuperview];
    }
    [(CFAnalyticView *)self.analyticView buildGraphInView:self.graphView];
}

@end
