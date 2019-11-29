#import "WelcomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "LoginTableViewController.h"
#import "LoginWebViewController.h"

@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *apiKeyButton;
@property (weak, nonatomic) IBOutlet UIButton *passwordButton;
@property (nonatomic, copy, nonnull) void (^finishedBlock)(void);

@end

@implementation WelcomeViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    self.apiKeyButton.layer.cornerRadius = 5.0f;
    self.apiKeyButton.clipsToBounds = YES;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)presentOnViewController:(UIViewController *)parent finished:(void (^)(void))finished {
    [parent presentViewController:self animated:YES completion:nil];
    self.finishedBlock = finished;
}

- (IBAction) apiKeyButton:(UIButton *)sender {
    LoginTableViewController * loginController = viewControllerFromStoryboard(STORYBOARD_MAIN, @"Login");
    [loginController performLogin:self finished:^(NSError * error, CFCredentials * key) {
        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:nil];
        } else if (key) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:^{
                    self.finishedBlock();
                }];
            });
        }
    }];
}

- (IBAction) passwordButton:(UIButton *)sender {
    LoginWebViewController * loginController = viewControllerFromStoryboard(STORYBOARD_MAIN, @"Login Web");
    [loginController performLogin:self finished:^(NSError * error, CFCredentials * key) {
        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:nil];
        } else if (key) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:^{
                    self.finishedBlock();
                }];
            });
        }
    }];
}

@end
