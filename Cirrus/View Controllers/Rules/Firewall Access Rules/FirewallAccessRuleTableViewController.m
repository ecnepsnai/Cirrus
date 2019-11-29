#import "FirewallAccessRuleTableViewController.h"
#import "CFFirewallAccessRuleConfiguration.h"
#import "CFFirewallAccessRuleScope.h"
#import "NSString+Validator.h"

@interface FirewallAccessRuleTableViewController () {
    void (^finishedCallback)(CFFirewallAccessRule *, BOOL);
}

@property (strong, nonatomic) CFFirewallAccessRule * rule;

@property (weak, nonatomic) IBOutlet UISegmentedControl *configTargetSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *configValueTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *actionSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scopeSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *notesTextField;

@property (strong, nonatomic) OCSelector * saveAction;
@property (strong, nonatomic) OCSelector * cancelAction;

@end

@implementation FirewallAccessRuleTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    switch (self.rule.configuration.target) {
        case FirewallAccessRuleConfigurationTargetIP:
            self.configTargetSegmentedControl.selectedSegmentIndex = 0;
            break;
        case FirewallAccessRuleConfigurationTargetIPRange:
            self.configTargetSegmentedControl.selectedSegmentIndex = 1;
            break;
        case FirewallAccessRuleConfigurationTargetCountry:
            self.configTargetSegmentedControl.selectedSegmentIndex = 2;
            break;
        case FirewallAccessRuleConfigurationTargetASN:
            self.configTargetSegmentedControl.selectedSegmentIndex = 3;
            break;
    }

    switch (self.rule.scope.type) {
        case FirewallAccessRuleScopeTypeZone:
            self.scopeSegmentedControl.selectedSegmentIndex = 0;
            break;
        case FirewallAccessRuleScopeTypeUser:
            self.scopeSegmentedControl.selectedSegmentIndex = 1;
            break;
    }

    switch (self.rule.mode) {
        case FirewallAccessRuleModeBlock:
            self.actionSegmentedControl.selectedSegmentIndex = 0;
            break;
        case FirewallAccessRuleModeWhitelist:
            self.actionSegmentedControl.selectedSegmentIndex = 1;
            break;
        case FirewallAccessRuleModeChallenge:
            self.actionSegmentedControl.selectedSegmentIndex = 2;
            break;
        case FirewallAccessRuleModeJSChallenge:
            self.actionSegmentedControl.selectedSegmentIndex = 3;
            break;
    }

    self.saveAction = [[OCSelector alloc] initWithBlock:^(id sender) {
        void (^apicallback)(BOOL success, NSError *error) = ^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgressControl];
            });
            if (error) {
                [uihelper presentErrorInViewController:self error:error dismissed:^(NSInteger buttonIndex) {
                    // let the user try again
                }];
            } else if (!success) {
                [uihelper
                 presentAlertInViewController:self
                 title:l(@"Unable to save rule")
                 body:l(@"An unexpected error occured while saving the page rule. Your changes may not have been saved.")
                 dismissButtonTitle:l(@"Dismiss")
                 dismissed:^(NSInteger buttonIndex) {
                     [self restoreViewFromSave];
                     self->finishedCallback(nil, YES);
                 }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self restoreViewFromSave];
                    self->finishedCallback(self.rule, NO);
                });
            }
        };

        NSError * validationError = [self validateRule];
        if (validationError) {
            [uihelper
             presentAlertInViewController:self
             title:l(@"Invalid Rule")
             body:validationError.localizedDescription
             dismissButtonTitle:l(@"Dismiss")
             dismissed:nil];
            return;
        }

        [authManager authenticateUserForChange:NO success:^{
            [self showProgressControl];
            if (self.rule.identifier) {
                [api updateFirewallAccessRule:currentZone rule:self.rule finished:apicallback];
            } else {
                [api createFirewallAccessRule:currentZone rule:self.rule finished:apicallback];
            }
        } cancelled:nil];
    }];
    self.cancelAction = [[OCSelector alloc] initWithBlock:^(id sender) {
        [self restoreViewFromSave];
        self->finishedCallback(nil, YES);
    }];

    self.configValueTextField.text = self.rule.configuration.value;
    self.notesTextField.text = self.rule.notes;
    if (self.rule.identifier) {
        self.title = l(@"Edit Rule");
        self.scopeSegmentedControl.enabled = NO;
    } else {
        self.title = l(@"Create Rule");
        self.scopeSegmentedControl.enabled = YES;
        [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) setRule:(CFFirewallAccessRule *)rule finished:(void (^)(CFFirewallAccessRule * rule, BOOL saved))finished {
    _rule = rule;
    finishedCallback = finished;
}

- (IBAction) configTargetSegmentedControl:(UISegmentedControl *)configTargetSegmentedControl {
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
    switch (configTargetSegmentedControl.selectedSegmentIndex) {
        case 0:
            self.rule.configuration.target = FirewallAccessRuleConfigurationTargetIP;
            break;
        case 1:
            self.rule.configuration.target = FirewallAccessRuleConfigurationTargetIPRange;
            break;
        case 2:
            self.rule.configuration.target = FirewallAccessRuleConfigurationTargetCountry;
            break;
        case 3:
            self.rule.configuration.target = FirewallAccessRuleConfigurationTargetASN;
            break;
    }
    self.configValueTextField.text = nil;
}

- (IBAction) configValueTextField:(UITextField *)configValueTextField {
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
    self.rule.configuration.value = configValueTextField.text;
}

- (IBAction) actionSegmentedControl:(UISegmentedControl *)actionSegmentedControl {
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
    switch (actionSegmentedControl.selectedSegmentIndex) {
        case 0:
            self.rule.mode = FirewallAccessRuleModeBlock;
            break;
        case 1:
            self.rule.mode = FirewallAccessRuleModeWhitelist;
            break;
        case 2:
            self.rule.mode = FirewallAccessRuleModeChallenge;
            break;
        case 3:
            self.rule.mode = FirewallAccessRuleModeJSChallenge;
            break;
    }
}

- (IBAction) scopeSegmentedControl:(UISegmentedControl *)scopeSegmentedControl {
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
    if (self.rule.identifier) {
        return;
    }

    if (scopeSegmentedControl.selectedSegmentIndex == 0) {
        self.rule.scope.type = FirewallAccessRuleScopeTypeZone;
        self.rule.scope.value = currentZone.identifier;
    } else {
        self.rule.scope.type = FirewallAccessRuleScopeTypeUser;
        self.rule.scope.value = appState.userEmail;
    }
}

- (IBAction) notesTextField:(UITextField *)notesTextField {
    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
    if (notesTextField.text.length > 0) {
        self.rule.notes = notesTextField.text;
    } else {
        self.rule.notes = nil;
    }
}

- (NSError *) validateRule {
    if (self.configValueTextField.text.length == 0) {
        return NSMakeError(-1, @"Must provide a rule configuration value");
    }

    if (self.configTargetSegmentedControl.selectedSegmentIndex == 3) { // ASN
        if (![self.configValueTextField.text hasPrefix:@"AS"]) {
            // ASN rules have to be prefixed with AS, rather than showing a useless
            // error to the user just patch it.
            // I deserve a UX award for this. 🏆
            self.rule.configuration.value = nstrcat(@"AS", self.rule.configuration.value);
        }
        NSError * ASNValidationError = [self.configValueTextField.text validASN];
        if (ASNValidationError) {
            return ASNValidationError;
        }
    }

    return nil;
}

@end
