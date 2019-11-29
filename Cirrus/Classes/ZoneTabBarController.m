#import "ZoneTabBarController.h"

@interface ZoneTabBarController ()

@end

@implementation ZoneTabBarController

- (void) viewDidLoad {
    [super viewDidLoad];

    // WTF?!?!?!?!?!?!?!
    self.delegate = self;
}

- (BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (appState.disableTabBarPopToRoot) {
        return viewController != tabBarController.selectedViewController;
    } else {
        return YES;
    }
}

@end
