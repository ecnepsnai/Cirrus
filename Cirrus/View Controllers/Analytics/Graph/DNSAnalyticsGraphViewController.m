#import "DNSAnalyticsGraphViewController.h"
#import "CFDNSAnalyticView.h"
#import "AnalyticsStatView.h"

@interface DNSAnalyticsGraphViewController ()

@property (weak, nonatomic) IBOutlet UIStackView *statViewsStack;
@property (strong, nonatomic) OCSelector * dataSelector;
@property (strong, nonatomic) OCSelector * loadSelector;
@property (strong, nonatomic) CFDNSAnalyticView * analyticView;
@property (nonatomic) CFDNSAnalyticsTimeframe currentTimeframe;

@end

@implementation DNSAnalyticsGraphViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.currentTimeframe = CFDNSAnalyticsTimeframe6Hours;
    self.dataSelector = [OCSelector selectorWithTarget:self action:@selector(didRecieveData:)];
    self.loadSelector = [OCSelector selectorWithTarget:self action:@selector(loadData)];
    self.statViewsStack.hidden = YES;
    [self changeTimeframe];
}

- (IBAction) changeTime:(UIBarButtonItem *)sender {
    NSArray<NSString *> * choices = @[
                                      l(@"Last 30 Minutes"),
                                      l(@"Last 6 Hours")
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
             [self changeTimeframe];
         }
     }];
}

- (void) changeTimeframe {
    [self showProgressControl];

    [api dnsAnalyticsForZone:currentZone timeframe:self.currentTimeframe finished:^(CFDNSAnalyticsResults *results, NSError *error) {
        [self hideProgressControl];

        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:nil];
        } else {
            self.analyticView = [CFDNSAnalyticView new];
            self.analyticView.results = results;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statViewsStack.hidden = NO;
                nTimes(2) {
                    [self buildStatViewAtIndex:i];
                }
            });
        }
    }];
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
    view.timeframeLabel.text = self.currentTimeframe == CFDNSAnalyticsTimeframe6Hours ? l(@"6 hours") : l(@"30 Minutes");
    view.valueLabel.text = [self.analyticView statViewAmountForIndex:index];
}

@end
