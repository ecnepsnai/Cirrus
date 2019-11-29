#import "UIViewController+ProgressControl.h"

@implementation UIViewController (ProgressControl)

static MBProgressHUD * hud;

- (void) showProgressControl {
    if (hud) {
        return;
    }

    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        });
    } else {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

- (void) hideProgressControl {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            hud = nil;
        });
    } else {
        [hud hideAnimated:YES];
        hud = nil;
    }
}

@end
