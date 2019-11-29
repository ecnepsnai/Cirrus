#import "LoginWebViewController.h"
#import "NSString+Validator.h"
#import "LoginTableViewController.h"
@import WebKit;
@import OnePasswordExtension;
@import LocalAuthentication;
@import QuartzCore;

@interface LoginWebViewController () <WKNavigationDelegate, WKScriptMessageHandler> {
    NSString * userEmail;
    NSString * apiKey;
}

@property (weak, nonatomic) IBOutlet UIView * webViewFrame;
@property (strong, nonatomic) WKWebView * webView;
@property (strong, nonatomic) CFCredentials * credentials;

@property (weak, nonatomic) IBOutlet UIView *guideView;
@property (weak, nonatomic) IBOutlet UILabel *guideLabel;
@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UISwitch *touchIDSwitch;
@property (weak, nonatomic) IBOutlet UILabel *touchIDLabel;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;

@end

// These values need to be kept *NSYNC with those in app.js
/// Triggered when the email input is found
#define EVENT_INPUT_FOUND @"EVENT_INPUT_FOUND"
/// Triggered when an error event occurs
#define EVENT_ERROR @"EVENT_ERROR"
/// Triggered when the email address value is ready. Substract key from message body.
#define EVENT_EMAIL_VALUE @"EVENT_EMAIL_VALUE"
/// Triggered when the "View API Key" button was located and scrolled into view.
#define EVENT_PRESS_BUTTON @"EVENT_PRESS_BUTTON"
/// Triggered when the "View API Key" button was pressed
#define EVENT_SOLVE_CAPTCHA @"EVENT_SOLVE_CAPTCHA"
/// Triggered when the API key value is ready. Subtract key from message body.
#define EVENT_KEY_VALUE @"EVENT_KEY_VALUE"

#define BASE_URL @"https://dash.cloudflare.com"
#define PROFILE_PATH @"/profile"
#define PROFILE_URL BASE_URL PROFILE_PATH

@implementation LoginWebViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self setGuideText:[lang key:@"Login to Cloudflare"]];
    
    WKWebViewConfiguration * configuration = [WKWebViewConfiguration new];
    WKUserContentController * controller = [WKUserContentController new];
    [controller addScriptMessageHandler:self name:@"observe"];
    configuration.userContentController = controller;
    configuration.websiteDataStore = [WKWebsiteDataStore nonPersistentDataStore];

    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) configuration:configuration];
    self.webView.navigationDelegate = self;

    // This will redirect to the login page
    [self.webView loadRequest:[NSURLRequest requestWithURL:url(PROFILE_URL)]];
    [self.webViewFrame addSubview:self.webView];

    switch (OCAuthenticationManager.currentAuthenticationMode) {
        case OCAuthenticationTypeBiometric:
        case OCAuthenticationTypePasscode:
            self.touchIDLabel.hidden = NO;
            self.touchIDSwitch.hidden = NO;
            self.touchIDLabel.text = [lang key:@"Use {authMode}" args:@[OCAuthenticationManager.authenticationTypeString]];
            [self.touchIDSwitch setOn:YES];
            break;
        case OCAuthenticationTypeNone:
            self.touchIDLabel.hidden = YES;
            self.touchIDSwitch.hidden = YES;
            [self.touchIDSwitch setOn:NO];
            break;
    }

    if (self.addAdditionalAccount) {
        self.touchIDLabel.hidden = YES;
        self.touchIDSwitch.hidden = YES;
    }

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelLogin:)];
    [self showProgressControl];
}

- (void) cancelLogin:(UIBarButtonItem *)sender {
    if (self.finishedBlock != nil) {
        self.finishedBlock(nil, nil);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) addBorder {
    CALayer * topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.toolView.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithRed:0.886f green:0.886f blue:0.886f alpha:1.0f].CGColor;
    [self.toolView.layer addSublayer:topBorder];
}

- (void) viewDidLayoutSubviews {
    CGRect viewFrame = self.webViewFrame.frame;
    CGRect newFrame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
    self.webView.frame = newFrame;
    [self addBorder];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self loadApplicationJavascript:^{
        NSString * page = webView.URL.path;
        self.navigationItem.title = webView.URL.absoluteString;

        dispatch_async(dispatch_get_main_queue(), ^{
            self.webView.userInteractionEnabled = NO;
            [self showProgressControl];
        });
        [self.webView evaluateJavaScript:@"hideSalesLink();" completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.webView.userInteractionEnabled = YES;
                [self hideProgressControl];
            });
        }];

        if ([page isEqualToString:@"/login"]) {
            [self.webView
             evaluateJavaScript:@"getEmail();"
             completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                 if (!error) {
                     cd(LOGIN_DEBUG, @"Triggered email retrival");
                 } else {
                     cd(LOGIN_DEBUG, @"Error while getting email: %@", error);
                     [self showFallbackLoginScreen];
                 }
             }];
        } else if ([page isEqualToString:PROFILE_PATH]) {
            [self.webView
             evaluateJavaScript:@"getAPIKey();"
             completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                 if (!error) {
                     cd(LOGIN_DEBUG, @"Triggered API Key retrival");
                 } else {
                     cd(LOGIN_DEBUG, @"Error while getting API key: %@", error);
                     [self showFallbackLoginScreen];
                 }
             }];
        } else if ([page hasPrefix:@"/overview"]
                   || [page isEqualToString:@"/sign-up"]
                   || [page isEqualToString:@"/"]
                   || [page hasPrefix:@"/plans"]) {
            cd(LOGIN_DEBUG, @"Browser redirected to somewhere bad, navigating to account settings");
            [self.webView
             evaluateJavaScript:@"goToAccountSettings();"
             completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                 if (error) {
                     cd(LOGIN_DEBUG, @"Error trying to redirect to account settings: %@", error);
                     [self showFallbackLoginScreen];
                 }
             }];
        }
#if LOGIN_DEBUG
        else {
            d(@"Unknown page: %@", page);
        }
#endif
    }];
}

- (void) userContentController:(WKUserContentController *)userContentController
       didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString * body = message.body;
    if ([body isEqualToString:EVENT_INPUT_FOUND]) {
        cd(LOGIN_DEBUG, @"Email input located!");
    } else if ([body hasPrefix:EVENT_ERROR]) {
        cd(LOGIN_DEBUG, @"Login general failure: %@", [body substringFromIndex:EVENT_ERROR.length]);
        [self showFallbackLoginScreen];
    } else if ([body hasPrefix:EVENT_EMAIL_VALUE]) {
        userEmail = [body substringFromIndex:EVENT_EMAIL_VALUE.length];
        cd(LOGIN_DEBUG, @"Email: %@", userEmail);
    } else if ([body hasPrefix:EVENT_PRESS_BUTTON]) {
        [self setGuideText:[lang key:@"Tap \"View\" beside \"Global API Key\""]];
    } else if ([body hasPrefix:EVENT_SOLVE_CAPTCHA]) {
        [self setGuideText:[lang key:@"Enter password & solve CAPTCHA"]];
    } else if ([body hasPrefix:EVENT_KEY_VALUE]) {
        apiKey = [body substringFromIndex:EVENT_KEY_VALUE.length];
        cd(LOGIN_DEBUG, @"API Key: %@", apiKey);
    }
    [self validateCredentials];
}

- (void) setGuideText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.guideLabel.text = text;
    });
}

- (void) performLogin:(UIViewController * _Nonnull)sender
             finished:(void (^ _Nonnull)(NSError * _Nullable, CFCredentials * _Nullable))finished {
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    [sender presentViewController:navigationController animated:YES completion:nil];
    self.finishedBlock = finished;
}

- (void) validateCredentials {
    if ([userEmail validateEmailAddress] == nil && apiKey.length == 37) {

        self.credentials = [CFCredentials new];
        self.credentials.email = userEmail;
        self.credentials.key = apiKey;

        [api getUserDetailsForAccount:self.credentials finished:^(NSDictionary<NSString *,id> *userInfo, NSError *error) {
            [self hideProgressControl];

            if (error) {
                [uihelper presentErrorInViewController:self error:error dismissed:^(NSInteger buttonIndex) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:YES completion:^{
                            self.finishedBlock(error, nil);
                        }];
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.touchIDSwitch.isOn) {
                        UserOptions.deviceLock = YES;
                        UserOptions.deviceLockChanges = YES;
                    }
                    [keyManager saveCredentials:self.credentials];
                    [self dismissViewControllerAnimated:YES completion:^{
                        self.finishedBlock(nil, self.credentials);
                    }];
                });
            }
        }];
    }
}

- (void) loadApplicationJavascript:(void (^)(void))finished {
    NSString * appJSPath = [[NSBundle mainBundle] pathForResource:@"app" ofType:@"js"];
    [self.webView
     evaluateJavaScript:[NSString stringWithContentsOfFile:appJSPath encoding:NSUTF8StringEncoding error:nil]
     completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if (!error) {
            finished();
        } else {
            cd(LOGIN_DEBUG, @"Error loading app.js: %@", error);
            [self showFallbackLoginScreen];
        }
    }];
}

- (void) showFallbackLoginScreen {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.webView = nil;
        LoginTableViewController * loginTable = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
        loginTable.addAdditionalAccount = self.addAdditionalAccount;
        loginTable.finishedBlock = self.finishedBlock;
        [self.navigationController setViewControllers:@[loginTable]];
    });
}

- (IBAction) optionsButton:(UIButton *)sender {
    [uihelper
     presentActionSheetInViewController:self
     attachToTarget:[ActionTipTarget targetWithView:sender]
     title:l(@"Login Options")
     subtitle:nil
     cancelButtonTitle:l(@"Cancel")
     items:@[l(@"Password Manager"), l(@"Login using Email & API Key")]
     dismissed:^(NSInteger itemIndex) {
         if (itemIndex == 0) {
             [[OnePasswordExtension sharedExtension]
              fillItemIntoWebView:self.webView
              forViewController:self
              sender:sender
              showOnlyLogins:NO
              completion:^(BOOL success, NSError *error) {
                  if (!success) {
                      cd(LOGIN_DEBUG, @"Failed to fill into webview: <%@>", error);
                  }
              }];
         } else if (itemIndex == 1) {
             [self showFallbackLoginScreen];
         }
     }];
}

@end
