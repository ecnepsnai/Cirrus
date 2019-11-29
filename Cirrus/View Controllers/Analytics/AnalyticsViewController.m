#import "AnalyticsViewController.h"

@interface AnalyticsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *timeframeButton;
@property (strong, nonatomic) CFAnalyticsResults * data;
@property (strong, nonatomic) NSMutableArray<OCSelector *> * dataObservers;
@property (strong, nonatomic) NSMutableArray<OCSelector *> * loadObservers;

@end

@implementation AnalyticsViewController

typedef NS_ENUM(NSInteger, AnalyticsPage) {
    AnalyticsPageGraph = 0,
    AnalyticsPageDNS = 1,
    AnalyticsPageStats = 2,
};

- (void) viewDidLoad {
    [super viewDidLoad];

    self.currentTimeframe = CFAnalyticsTimeframe24Hours;
    self.dnsTimeframe = CFDNSAnalyticsTimeframe6Hours;

    [self addZoneMenuButtonWithTitle:l(@"Analytics")];
    subscribe(@selector(zoneChanged:), NOTIF_ZONE_CHANGED);
    [self loadData];
}

- (void) zoneChanged:(NSNotification *)n {
    [self loadData];
}

- (void) loadData {
    self.timeframeButton.enabled = NO;
    [self showProgressControl];
    for (OCSelector * action in self.loadObservers) {
        [action performActionOnSender];
    }

    [api analyticsForZone:currentZone timeframe:self.currentTimeframe finished:^(CFAnalyticsResults *results, NSError *error) {
        [self hideProgressControl];
        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:nil];
        }

        self.data = results;
        for (OCSelector * action in self.dataObservers) {
            [action performActionOnSenderWithObject:results];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.timeframeButton.enabled = YES;
        });
    }];
}

- (IBAction) changeTime:(UIBarButtonItem *)sender {
    if (self.pageControl.currentPage == AnalyticsPageDNS) {
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
                 self.dnsTimeframe = itemIndex;
                 notify(NOTIF_DNS_TIMEFRAME_CHANGED);
             }
         }];
    } else {
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
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) setDataObservationsWithRecievedData:(OCSelector *)recievedData loadStarted:(OCSelector *)loadData {
    if (self.data) {
        if (recievedData) {
            [recievedData performActionOnSenderWithObject:self.data];
        }
    }

    if (!self.dataObservers) {
        self.dataObservers = [NSMutableArray new];
    }
    if (recievedData) {
        [self.dataObservers addObject:recievedData];
    }
    if (!self.loadObservers) {
        self.loadObservers = [NSMutableArray new];
    }
    if (loadData) {
        [self.loadObservers addObject:loadData];
    }
}

@end
