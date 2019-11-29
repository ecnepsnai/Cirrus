#import "OCSplitViewController.h"

@interface OCSplitViewController ()

@end

@implementation OCSplitViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    appState.splitViewController = self;
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    if (isRegular) {
        UIViewController * placeholder = [self.storyboard instantiateViewControllerWithIdentifier:@"Placeholder Navigation Controller"];
        [self showDetailViewController:placeholder sender:self];
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL) detailViewControllerIsPlaceholder {
    if (self.viewControllers.count != 2) {
        return YES; // Indicate that it needs to be replaced
    }
    return [[[self.viewControllers lastObject] title] isEqualToString:@"Placeholder"];
}

@end
