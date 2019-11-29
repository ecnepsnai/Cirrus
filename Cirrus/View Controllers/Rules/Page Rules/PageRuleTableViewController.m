#import "PageRuleTableViewController.h"
#import "PageRuleValueTableViewController.h"

@interface PageRuleTableViewController () {
    void (^finishedCallback)(CFPageRule *, BOOL);
}

@property (strong, nonatomic) CFPageRule * rule;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> * mutatedActions;
@property (nonatomic) BOOL targetChanged;
@property (strong, nonatomic) UISwitch * enabledSwitch;
@property (strong, nonatomic) OCSelector * saveAction;
@property (strong, nonatomic) OCSelector * cancelAction;

@end

@implementation PageRuleTableViewController

- (void) viewDidLoad {
    if (self.rule.identifier.length > 0) {
        self.title = l(@"Edit Rule");
    } else {
        self.title = l(@"Create New Rule");
    }

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [super viewDidLoad];
    self.mutatedActions = [NSMutableDictionary new];

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
                 title:l(@"Unable to save page rule")
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
        [authManager authenticateUserForChange:NO success:^{
            [self showProgressControl];
            if (self.rule.identifier) {
                [api updateZonePageRule:currentZone rule:self.rule finished:apicallback];
            } else {
                [api createZonePageRule:currentZone rule:self.rule finished:apicallback];
            }
        } cancelled:nil];
    }];
    self.cancelAction = [[OCSelector alloc] initWithBlock:^(id sender) {
        [self restoreViewFromSave];
        self->finishedCallback(nil, YES);
    }];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) setRule:(CFPageRule *)rule finished:(void (^)(CFPageRule * rule, BOOL saved))finished {
    _rule = rule;
    finishedCallback = finished;
}

- (BOOL) canAddNewAction {
    return ([self availableActionsForRule].count > 0);
}

- (void) addAction:(UIButton *)sender {
    NSArray<NSString *> * choices = [self availableActionsForRule];
    NSMutableArray<NSString *> * titles = [NSMutableArray arrayWithCapacity:choices.count];
    for (NSString * choice in choices) {
        [titles addObject:l(format(@"pagerule::%@", choice))];
    }

    [uihelper
     presentActionSheetInViewController:self
     attachToTarget:[ActionTipTarget targetWithView:sender]
     title:l(@"Add Action")
     subtitle:nil
     cancelButtonTitle:l(@"Cancel")
     items:titles
     dismissed:^(NSInteger itemIndex) {
         if (itemIndex != -1) {
             CFPageRuleAction * action = [CFPageRuleAction new];
             action.identifier = choices[itemIndex];
             NSMutableArray<CFPageRuleAction *> * ruleActions = [NSMutableArray arrayWithArray:self.rule.actions];
             [ruleActions addObject:action];
             self.rule.actions = ruleActions;
             [self presentActionController:action];
         }
     }];
}

- (NSArray<NSString *> *) availableActionsForRule {
    NSDictionary * mapping = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Page Rules" ofType:@"plist"]];
    NSArray<NSString *> * actions = mapping.allKeys;
    NSMutableArray<NSString *> * titles = [NSMutableArray new];
    NSUInteger numberOfActions = self.rule.actions.count;
    BOOL addAction;
    NSArray<NSString *> * collidesWith;
    NSDictionary<NSString *, id> * map;

    if (numberOfActions == 1) {
        if (self.rule.actions[0].exclusive) {
            return titles;
        }
    }

    for (NSString * choice in actions) {
        addAction = YES;
        if (numberOfActions > 0) {
            map = [mapping dictionaryForKey:choice];
            if ([map boolForKey:@"exclusive"]) {
                continue; // Remove exclusive actions
            }

            collidesWith = [map arrayForKey:@"collides_with"];
            for (CFPageRuleAction * action in self.rule.actions) {
                if ([action.identifier isEqualToString:choice]) {
                    addAction = NO; // Remove duplicate actions
                }

                if (collidesWith) {
                    if ([collidesWith containsObject:action.identifier]) {
                        addAction = NO; // Remove actions that collide with pre-existing actions in the rule
                    }
                }
            }
        }
        if (addAction) {
            [titles addObject:choice];
        }
    }

    return titles;
}

- (void) presentActionController:(CFPageRuleAction *)action {
    UIViewController * valueViewController;
    if (action.type == CFPageSettingForwardingUrl) {
        valueViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageRuleForwardURL"];
    } else {
        valueViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageRuleEditValue"];
    }
    [(PageRuleValueTableViewController *)valueViewController setAction:action finished:^(BOOL cancelled, id newValue) {
        if (!cancelled) {
            [self.mutatedActions setObject:@1 forKey:action.identifier];
            action.value = newValue;
            [self.tableView reloadData];
            [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
        }
    }];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:valueViewController] animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1: {
            NSUInteger baseCount = self.rule.actions.count;
            if ([self canAddNewAction]) {
                baseCount ++;
            }
            return baseCount;
        } case 2:
            return 1;
    }

    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return l(@"If the URL matches:");
        case 1:
            return l(@"Then set these settings:");
    }

    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return l(@"Use the wildcard (*) to match multiple requests.");
        case 1: {
            if (![self canAddNewAction]) {
                return l(@"No more actions can be added to this page rule.");
            }
        }
    }

    return nil;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row < self.rule.actions.count) {
        return YES;
    }

    return NO;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;

    switch (indexPath.section) {
        case 0: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Target" forIndexPath:indexPath];
            UITextField * targetText = [cell viewWithTag:10];
            targetText.text = self.rule.target;
            [targetText addSelector:[[OCSelector alloc] initWithBlock:^(id sender) {
                self.rule.target = targetText.text;
                if (!self.targetChanged) {
                    [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
                    self.targetChanged = YES;
                }
            }] forControlEvent:UIControlEventEditingChanged];
            if (!self.rule.identifier) {
                [targetText becomeFirstResponder];
            }
            break;
        } case 1: {
            if (indexPath.row == self.rule.actions.count) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"AddAction" forIndexPath:indexPath];
                UIButton * addActionButton = [cell viewWithTag:10];
                [addActionButton setTitle:l(@"Add Action") forState:UIControlStateNormal];
                [addActionButton addTarget:self action:@selector(addAction:)
                          forControlEvents:UIControlEventTouchUpInside];
                addActionButton.enabled = [self canAddNewAction];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"Action" forIndexPath:indexPath];
                CFPageRuleAction * action = [self.rule.actions objectAtIndex:indexPath.row];
                cell.textLabel.text = l(format(@"pagerule::%@", action.identifier));
                if ([self.mutatedActions objectForKey:action.identifier]) {
                    cell.textLabel.textColor = [UIColor materialOrange];
                }
            }
            break;
        } case 2: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Switch" forIndexPath:indexPath];
            UILabel * label = [cell viewWithTag:10];
            label.text = l(@"Enable Rule");
            self.enabledSwitch = [cell viewWithTag:15];
            self.enabledSwitch.on = self.rule.enabled;
            [self.enabledSwitch addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
                [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
                self.rule.enabled = sender.on;
            }] forControlEvent:UIControlEventTouchUpInside];
        }
    }

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        CFPageRuleAction * action = [self.rule.actions objectAtIndex:indexPath.row];
        [self presentActionController:action];
    }
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray * actions = [NSMutableArray arrayWithArray:self.rule.actions];
        [actions removeObjectAtIndex:indexPath.row];
        self.rule.actions = [NSArray arrayWithArray:actions];
        [self.tableView reloadData];
        [self updateViewForSave:self.saveAction confirmSave:NO cancelAction:self.cancelAction confirmCancel:YES];
    }
}

@end
