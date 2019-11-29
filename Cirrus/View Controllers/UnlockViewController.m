#import "UnlockViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface UnlockViewController ()

@property (weak, nonatomic) IBOutlet UIButton *unlockButton;
@property (strong, nonatomic) LAContext * authContext;
@property (strong, nonatomic) NSString * reason;
@property (nonatomic, copy) void (^finishedBlock)(void);

@end

@implementation UnlockViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    [uihelper applyStylesToButton:self.unlockButton withColor:[uihelper cirrusColor]];
    self.unlockButton.hidden = YES;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) authenticateWithReason:(NSString *)reason finished:(void (^)(void))finished {
    self.reason = reason;
    self.finishedBlock = finished;
    [self authenticate];
}

- (void) authenticate {
    if (!self.authContext) {
        self.authContext = [LAContext new];
    }
    [self.authContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:self.reason reply:^(BOOL success, NSError * _Nullable error) {
        self.authContext = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil && success) {
                self->_finishedBlock();
            } else {
                self.unlockButton.hidden = NO;
            }
        });
    }];
}

- (IBAction) unlockButtonPressed:(UIButton *)sender {
    [self authenticate];
}

@end
