#import "DNSAnalyticsViewController.h"
#import "CFDNSAnalyticView.h"

@interface DNSAnalyticsViewController ()

@property (weak, nonatomic) IBOutlet UIView *graphView;
@property (nonatomic) CFDNSAnalyticsTimeframe currentTimeframe;
@property (strong, nonatomic) CFDNSAnalyticView * analyticView;

@end

@implementation DNSAnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentTimeframe = CFDNSAnalyticsTimeframe6Hours;
    self.analyticView = [CFDNSAnalyticView new];
    [self loadData];
}

- (IBAction)timeframeButton:(id)sender {
    NSArray<NSString *> * choices = @[
                                      l(@"Last 30 Minutes"),
                                      l(@"Last 6 Hours"),
                                      l(@"Last 12 Hours"),
                                      l(@"Last 24 Hours"),
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
    [api dnsAnalyticsForZone:currentZone timeframe:self.currentTimeframe finished:^(CFDNSAnalyticsResults *results, NSError *error) {
        [self hideProgressControl];
        
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [uihelper presentErrorInViewController:self error:error dismissed:nil];
            });
            return;
        }

        self.analyticView = [CFDNSAnalyticView viewWithResults:results];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self buildGraph];
        });
    }];
}

- (void) buildGraph {
    for (UIView * subview in self.graphView.subviews) {
        [subview removeFromSuperview];
    }
    [self.analyticView buildGraphInView:self.graphView];
}

@end
