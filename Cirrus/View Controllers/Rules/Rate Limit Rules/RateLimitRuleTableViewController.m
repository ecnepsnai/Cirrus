#import "RateLimitRuleTableViewController.h"

@interface RateLimitRuleTableViewController (){
    void (^finishedCallback)(CFRateLimit *, BOOL);
}

@property (strong, nonatomic) CFRateLimit * rule;
@property (strong, nonatomic) OCSelector * saveAction;
@property (strong, nonatomic) OCSelector * cancelAction;

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UISwitch *enabledSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *protocolToggle;
@property (weak, nonatomic) IBOutlet UITextField *urlInput;
@property (weak, nonatomic) IBOutlet UITextField *thresholdInput;
@property (weak, nonatomic) IBOutlet UITextField *rateInput;
@property (weak, nonatomic) IBOutlet UITextField *timeoutInput;

@end

@implementation RateLimitRuleTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    [self.enabledSwitch setOn:self.rule.enabled];
    self.name.text = self.rule.comment;
    self.urlInput.text = self.rule.match.request.url;

    NSString * scheme = self.rule.match.request.schemes[0];
    if ([scheme isEqualToString:@"_ALL_"]) {
        [self.protocolToggle setSelectedSegmentIndex:0];
    } else if ([scheme isEqualToString:@"HTTP"]) {
        [self.protocolToggle setSelectedSegmentIndex:1];
    } else if ([scheme isEqualToString:@"HTTPS"]) {
        [self.protocolToggle setSelectedSegmentIndex:2];
    }

    self.thresholdInput.text = format(@"%lu", (unsigned long)self.rule.threshold);
    self.rateInput.text = format(@"%lu", (unsigned long)self.rule.period);
    self.timeoutInput.text = format(@"%lu", (unsigned long)self.rule.action.timeout);

    self.saveAction = [[OCSelector alloc] initWithBlock:^(id sender) {
        [authManager authenticateUserForChange:NO success:^{
            [self showProgressControl];
            [api updateRateLimitForZone:currentZone limit:self.rule finished:^(BOOL success, NSError *error) {
                [self hideProgressControl];
                if (error) {
                    [uihelper presentErrorInViewController:self error:error dismissed:nil];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self restoreViewFromSave];
                        [self.navigationController popViewControllerAnimated:YES];
                        self->finishedCallback(self.rule, YES);
                    });
                }
            }];
        } cancelled:nil];
    }];
    self.cancelAction = [[OCSelector alloc] initWithBlock:^(id sender) {
        [self restoreViewFromSave];
        [self dismissViewControllerAnimated:YES completion:^{
            self->finishedCallback(self.rule, NO);
        }];
    }];
    
    if (!self.rule.identifier) {
        [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
        self.title = l(@"New Rule");
    } else {
        self.title = self.rule.comment;
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.rule.loginProtect) {
        return 1;
    } else {
        return 4;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (self.rule.loginProtect && section == 0) {
        return l(@"You cannot modify settings of a login rate limit rule.");
    }
    return nil;
}

- (void) setRule:(CFRateLimit *)rule finished:(void (^)(CFRateLimit * rule, BOOL saved))finished {
    self.rule = rule;
    finishedCallback = finished;
}

- (IBAction) editName:(UITextField *)sender {
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
    self.rule.comment = sender.text;
}

- (IBAction) setEnabled:(UISwitch *)sender {
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
    self.rule.enabled = sender.isOn;
}

- (IBAction) changeProtocol:(UISegmentedControl *)sender {
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
    if (sender.selectedSegmentIndex == 0) {
        self.rule.match.request.schemes = @[@"_ALL_"];
    } else if (sender.selectedSegmentIndex == 1) {
        self.rule.match.request.schemes = @[@"HTTP"];
    } else if (sender.selectedSegmentIndex == 2) {
        self.rule.match.request.schemes = @[@"HTTPS"];
    }
}

- (IBAction) editURL:(UITextField *)sender {
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
    self.rule.match.request.url = sender.text;
}

- (IBAction) editThreshold:(UITextField *)sender {
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
    NSInteger threshold = [sender.text integerValue];
    if (threshold >= 2 && threshold <= 5000) {
        self.rule.threshold = threshold;
    }
}

- (IBAction) editRate:(UITextField *)sender {
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
}

- (IBAction) editTimeout:(UITextField *)sender {
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
}

@end
