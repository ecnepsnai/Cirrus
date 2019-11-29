#import "AppDelegate.h"
#import "UnlockViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@property (strong, nonatomic) UnlockViewController * backgroundLockViewController;

@end

@implementation AppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([[OCAuthenticationManager sharedInstance] authenticationEnabled]) {
        UnlockViewController * unlockController = viewControllerFromStoryboard(@"Main", @"Unlock");
        unlockController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.window.rootViewController = unlockController;
        [self.window makeKeyAndVisible];
        [unlockController authenticateWithReason:l(@"Authenticate to access Cirrus") finished:^{
            UIViewController * initialController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
            [initialController.view addSubview:unlockController.view];
            self.window.rootViewController = initialController;
            [UIView animateWithDuration:0.25f animations:^{
                unlockController.view.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [unlockController.view removeFromSuperview];
            }];
        }];
    }

    return YES;
}

- (void) applicationWillResignActive:(UIApplication *)application { }

- (void) applicationDidEnterBackground:(UIApplication *)application {
    // Only show the lock controller if the user has signed in
    // Otheruse if the user leaves the app during login (i.e. for two factor)
    // they'll be presented with the auth screen
    if (appState.isLoggedIn && UserOptions.deviceLock) {
        self.backgroundLockViewController = viewControllerFromStoryboard(@"Main", @"Unlock");
        [[self topMostController] presentViewController:self.backgroundLockViewController animated:NO completion:NULL];
    }
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
    if (self.backgroundLockViewController) {
        [self.backgroundLockViewController authenticateWithReason:l(@"Authenticate to access Cirrus") finished:^{
            [[self topMostController] dismissViewControllerAnimated:NO completion:nil];
            self.backgroundLockViewController = nil;
        }];
    }
}

- (void) applicationDidBecomeActive:(UIApplication *)application { }

- (void) applicationWillTerminate:(UIApplication *)application { }

- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    return topController;
}

@end
