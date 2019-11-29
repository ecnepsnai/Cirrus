#import "OCSplitViewController.h"

@interface OCSplitViewController ()

@end

@implementation OCSplitViewController

- (void) viewDidLoad {
    // Be your own boss!
    self.delegate = self;
    [super viewDidLoad];
    appState.splitViewController = self;

    if (self.displayMode == UISplitViewControllerDisplayModeAllVisible) {
        UIViewController * dnsController = viewControllerFromStoryboard(STORYBOARD_DNS, @"DNS");
        [self showDetailViewController:dnsController sender:nil];
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL) splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    // This ensures that the master view is shown on compact screens
    return YES;
}

@end
