#import "LoginTableViewController.h"
#import "NSString+Validator.h"
#import "LoginWebViewController.h"
@import MBProgressHUD;
@import LocalAuthentication;

@interface LoginTableViewController () <UITextFieldDelegate> {
    BOOL touchIDSupported;
}

@property (weak, nonatomic) UITextField * emailInput;
@property (weak, nonatomic) UITextField * keyInput;
@property (weak, nonatomic) UISwitch    * touchIDSwitch;

@property (strong, nonatomic) UITextView * helpTextView;
@property (strong, nonatomic) UIBarButtonItem * loginButton;
@property (strong, nonatomic) CFCredentials * key;
@property (strong, nonatomic) NSArray<NSString *> * cellLabels;

@end

@implementation LoginTableViewController

typedef NS_ENUM(NSInteger, LoginCellViewTag) {
    LoginCellViewTagLabel = 10,
    LoginCellViewTagInput = 15,
    LoginCellViewTagSwitch = 20
};

- (void) viewDidLoad {
    [super viewDidLoad];

    self.cellLabels = @[
                        l(@"Email Address"),
                        l(@"API Key"),
                        [lang key:@"Require {authentication_type}" args:@[OCAuthenticationManager.authenticationTypeString]],
                        ];

    self.loginButton = [[UIBarButtonItem alloc]
                        initWithTitle:[lang key:@"Login"]
                        style:UIBarButtonItemStyleDone
                        target:self action:@selector(login)];
    self.navigationItem.rightBarButtonItem = self.loginButton;
    self.loginButton.enabled = NO;

    self.helpTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.helpTextView.scrollEnabled = NO;
    self.helpTextView.selectable = NO;
    self.helpTextView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    NSString * htmlString = @"<ol style=\"font-family: -apple-system, sans-serif; color: #6D6D72\"> <li>Login to your Cloudflare account on a web browser</li> <li>In the top left, click on the user menu and select \"My Profile\" from the menu</li> <li>Scroll down to the \"API Keys\" section</li> <li>Beside \"Global API Key\" click the \"View\" button</li> </ol>";
    NSAttributedString * helpText = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                               NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding),
                                                                               }
                                                          documentAttributes:nil error:nil];

    self.helpTextView.attributedText = helpText;

    switch (OCAuthenticationManager.currentAuthenticationMode) {
        case OCAuthenticationTypeBiometric:
        case OCAuthenticationTypePasscode:
            touchIDSupported = YES;
            break;
        case OCAuthenticationTypeNone:
            touchIDSupported = NO;
            break;
    }

    if (self.addAdditionalAccount) {
        touchIDSupported = NO;
    }

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelLogin:)];

    self.title = [lang key:@"Login to Cloudflare"];
    [self checkClipboardContents];
}

- (void) cancelLogin:(UIBarButtonItem *)sender {
    if (self.finishedBlock != nil) {
        self.finishedBlock(nil, nil);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkClipboardContents];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) checkClipboardContents {
    NSString * clipboardContents = [UIPasteboard generalPasteboard].string;
    if (!clipboardContents) {
        return;
    }

    if ([self validateAPIKey:clipboardContents]) {
        [uihelper presentConfirmInViewController:self
                                           title:l(@"Use contents of clipboard?")
                                            body:l(@"You seem to have an API key copied to your clipboard, would you like to use it?")
                              confirmButtonTitle:l(@"Yes")
                               cancelButtonTitle:l(@"No")
                      confirmActionIsDestructive:NO
                                       dismissed:^(BOOL confirmed) {
                                           if (confirmed) {
                                               self.keyInput.text = clipboardContents;
                                               [self validateForm];
                                           }
                                       }];
    } else if ([clipboardContents validateEmailAddress] == nil) {
        [uihelper presentConfirmInViewController:self
                                           title:l(@"Use contents of clipboard?")
                                            body:l(@"You seem to have an email address copied to your clipboard, would you like to use it?")
                              confirmButtonTitle:l(@"Yes")
                               cancelButtonTitle:l(@"No")
                      confirmActionIsDestructive:NO
                                       dismissed:^(BOOL confirmed) {
                                           if (confirmed) {
                                               self.emailInput.text = clipboardContents;
                                               [self validateForm];
                                           }
                                       }];
    }
}

- (BOOL) validateAPIKey:(NSString *)key{
    return key.length == 37;
}

- (BOOL) validateForm {
    BOOL isValid = YES;

    if ([self.emailInput.text validateEmailAddress] != nil) {
        isValid = NO;
        d(@"Invalid email address");
    }
    if ([self.keyInput.text validateCloudflareAPIKey] != nil) {
        isValid = NO;
        d(@"Invalid cloudflare API key");
    }
    if (self.touchIDSwitch.isOn) {
        if (!touchIDSupported) {
            isValid = NO;
            d(@"TouchID enabled but not supported on this device?");
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.loginButton.enabled = isValid;
    });
    return isValid;
}

- (void) performLogin:(UIViewController * _Nonnull)sender finished:(void (^ _Nonnull)(NSError * _Nullable, CFCredentials * _Nullable))finished {
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    [sender presentViewController:navigationController animated:NO completion:nil];
    self.finishedBlock = finished;
}

- (void) login {
    if (![self validateForm]) {
        return;
    }

    self.key = [CFCredentials new];
    self.key.email = self.emailInput.text;
    self.key.key = self.keyInput.text;

    self.loginButton.enabled = NO;

    [self showProgressControl];

    [api getUserDetailsForAccount:self.key finished:^(NSDictionary<NSString *,id> *userInfo, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressControl];
        });

        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:nil];
        } else {
            [keyManager saveCredentials:self.key];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.touchIDSwitch.isOn) {
                    UserOptions.deviceLock = YES;
                    UserOptions.deviceLockChanges = YES;
                }
                [self dismissViewControllerAnimated:NO completion:^{
                    self.finishedBlock(nil, self.key);
                }];
            });
        }
    }];
}

- (void) help {
    UIViewController * helpView = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginHelp"];
    [self.navigationController pushViewController:helpView animated:YES];
}

- (IBAction) inputChange:(UITextField *)sender {
    [self validateForm];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

# pragma mark - Table View Methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return touchIDSupported ? 3 : 2;
    }
    return 1;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return l(@"Cloudflare Login Information");
    }

    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return l(@"login_keychain_description");
    }

    return nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;

    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Input" forIndexPath:indexPath];
                    if (!self.emailInput) {
                        self.emailInput = (UITextField *)[cell viewWithTag:LoginCellViewTagInput];
                        [self.emailInput addTarget:self action:@selector(inputChange:) forControlEvents:UIControlEventEditingChanged];
                        self.emailInput.keyboardType = UIKeyboardTypeEmailAddress;
                        self.emailInput.autocorrectionType = UITextAutocorrectionTypeNo;
                        self.emailInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    }
                    break;
                } case 1: {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Input" forIndexPath:indexPath];
                    if (!self.keyInput) {
                        self.keyInput = (UITextField *)[cell viewWithTag:LoginCellViewTagInput];
                        [self.keyInput addTarget:self action:@selector(inputChange:) forControlEvents:UIControlEventEditingChanged];
                        self.keyInput.keyboardType = UIKeyboardTypeASCIICapable;
                        self.keyInput.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
                        self.keyInput.spellCheckingType = UITextSpellCheckingTypeNo;
                        self.keyInput.autocorrectionType = UITextAutocorrectionTypeNo;
                    }
                    break;
                } case 2: {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Switch" forIndexPath:indexPath];
                    if (!self.touchIDSwitch) {
                        self.touchIDSwitch = (UISwitch *)[cell viewWithTag:LoginCellViewTagSwitch];
                        self.touchIDSwitch.on = YES;
                    }
                    break;
                } default: break;
            }

            UILabel * label = (UILabel *)[cell viewWithTag:LoginCellViewTagLabel];
            label.text = self.cellLabels[indexPath.row];

            return cell;
        } case 1: {
            return [tableView dequeueReusableCellWithIdentifier:@"Login" forIndexPath:indexPath];
        } default: break;
    }

    return nil;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return self.helpTextView;
    }

    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 100.0f;
    }

    return 0;
}

@end
