#import "OCAuthenticationManager.h"
#import "UnlockViewController.h"
@import LocalAuthentication;

@interface OCAuthenticationManager ()

@property (strong, nonatomic) LAContext * authContext;

@end

@implementation OCAuthenticationManager

static id _instance;
static UIVisualEffectView * blurView;

- (id) init {
    if (!_instance) {
        _instance = [super init];
    }
    return _instance;
}

+ (OCAuthenticationManager *) sharedInstance {
    if (!_instance) {
        _instance = [OCAuthenticationManager new];
    }
    return _instance;
}

- (BOOL) authenticationEnabled {
    return UserOptions.deviceLock;
}

- (void) authenticateUserWithReason:(NSString *)reason success:(void(^)(void))success {
    if ([OCAuthenticationManager currentAuthenticationMode] == OCAuthenticationTypeNone) {
        success();
        return;
    }

    UnlockViewController * unlockController = viewControllerFromStoryboard(@"Main", @"Unlock");
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:unlockController animated:YES completion:nil];
    [unlockController authenticateWithReason:reason finished:success];
}

- (void) authenticateUserForChange:(BOOL)dangerous success:(void(^)(void))success cancelled:(void (^)(void))cancelled {
    if ([OCAuthenticationManager currentAuthenticationMode] == OCAuthenticationTypeNone) {
        success();
        return;
    }

    BOOL authForChanges = UserOptions.deviceLockChanges;
    BOOL authForAllChanges = UserOptions.deviceLockAllChanges;
    if (authForChanges && (dangerous || authForAllChanges)) {
        if (!self.authContext) {
            self.authContext = [LAContext new];
        }
        [self.authContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:l(@"Authenticate to make change") reply:^(BOOL successful, NSError * _Nullable error) {
            self.authContext = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error == nil && successful) {
                    success();
                } else if (error.code == LAErrorUserCancel) {
                    if (cancelled != nil) {
                        cancelled();
                    }
                }
            });
        }];
    } else {
        success();
    }
}

- (BOOL) deviceSupportsAuthentication {
    return [[LAContext new] canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:nil];
}

- (UIViewController *) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    return topController;
}

- (void) blurApplicationContents {
    UIViewController * root = [self topMostController];

    if (!root) {
        return;
    }

    if (blurView) {
        // Blur view already present
        return;
    }
    
    UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = root.view.bounds;
    [root.view addSubview:blurView];
}

- (void) unblurApplicationContents {
    if (blurView) {
        [blurView removeFromSuperview];
    }
    blurView = nil;
}

+ (OCAuthenticationType) currentAuthenticationMode {
    if ([[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        d(@"Device supports biometric authentication");
        return OCAuthenticationTypeBiometric;
    } else if ([[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:nil]) {
        d(@"Device supports passcode authentication");
        return OCAuthenticationTypePasscode;
    } else {
        d(@"Device does not support any authentication");
        return OCAuthenticationTypeNone;
    }
}

+ (NSString *) authenticationTypeString {
    LAContext * context = [LAContext new];
    BOOL biometricSupported = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    if (biometricSupported) {
        if (@available(iOS 11, *)) {
            switch (context.biometryType) {
                case LABiometryTypeTouchID:
                    return @"Touch ID";
                case LABiometryTypeFaceID:
                    return @"Face ID";
                default:
                    return @"Passcode";
            }
        } else {
            return @"Touch ID";
        }
    } else {
        return @"Passcode";
    }
}

@end
