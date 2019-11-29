#import "FirewallAccessRulesListTableViewController.h"
#import "CFFirewallAccessRuleScope.h"
#import "FirewallAccessRuleTableViewController.h"

@interface FirewallAccessRulesListTableViewController () {
    BOOL hasGlobalRules;
    BOOL hasZoneRules;
}

@property (strong, nonatomic) NSArray<CFFirewallAccessRule *> * globalRules;
@property (strong, nonatomic) NSArray<CFFirewallAccessRule *> * zoneRules;
@property (strong, nonatomic) NSMutableArray<CFFirewallAccessRule *> * filteredGlobalRules;
@property (strong, nonatomic) NSMutableArray<CFFirewallAccessRule *> * filteredZoneRules;
@property (strong, nonatomic) UISearchController * searchController;

@end

@implementation FirewallAccessRulesListTableViewController

- (FirewallAccessRulesListTableViewController *) initWithParent:(RuleListViewController *)parent tableView:(UITableView *)tableView {
    self = [super init];

    self.parent = parent;
    self.tableView = tableView;
    self.globalRules = @[];
    self.zoneRules = @[];
    self.searchController = self.parent.searchController;
    [self loadData];

    return self;
}

- (void) createNew {
    CFFirewallAccessRule * rule = [CFFirewallAccessRule new];
    rule.scope = [CFFirewallAccessRuleScope new];
    rule.scope.type = FirewallAccessRuleScopeTypeZone;
    rule.configuration = [CFFirewallAccessRuleConfiguration new];
    rule.configuration.target = FirewallAccessRuleConfigurationTargetIP;
    rule.mode = FirewallAccessRuleModeBlock;
    rule.scope.value = currentZone.identifier;

    FirewallAccessRuleTableViewController * editView = [self.parent.storyboard instantiateViewControllerWithIdentifier:@"FirewallAccessRuleEdit"];
    [editView setRule:rule finished:^(CFFirewallAccessRule *rule, BOOL saved) {
        [self loadData];
    }];
    [self.parent.navigationController pushViewController:editView animated:YES];
}

- (void) loadData {
    [api getFirewallAccessRulesForZone:currentZone finished:^(NSArray<CFFirewallAccessRule *> *rules, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parent.refreshControl endRefreshing];
        });

        if (error) {
            [uihelper presentErrorInViewController:self.parent error:error dismissed:nil];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray<CFFirewallAccessRule *> * globalRules = [NSMutableArray arrayWithCapacity:rules.count];
                NSMutableArray<CFFirewallAccessRule *> * zoneRules = [NSMutableArray arrayWithCapacity:rules.count];

                self->hasGlobalRules = NO;
                self->hasZoneRules = NO;

                for (CFFirewallAccessRule * rule in rules) {
                    if (rule.scope.type == FirewallAccessRuleScopeTypeUser) {
                        [globalRules addObject:rule];
                        self->hasGlobalRules = YES;
                    } else {
                        [zoneRules addObject:rule];
                        self->hasZoneRules = YES;
                    }
                }

                self.globalRules = globalRules;
                self.zoneRules = zoneRules;

                [self.tableView reloadData];
                if (self.globalRules.count == 0 && self.zoneRules.count == 0) {
                    [[OCTipManager sharedInstance] showTip:^(CMPopTipView * _Nonnull tip) {
                        tip.message = l(@"No firewall access rules. Tap here to create new rule.");
                        [tip presentPointingAtBarButtonItem:self.parent.navigationItem.rightBarButtonItem animated:YES];
                    }];
                }
            });
        }
    }];
}

- (void) zoneChanged:(NSNotification *)n {
    [self loadData];
}

- (void) filterRules:(NSString *)query {
    self.filteredZoneRules = [NSMutableArray arrayWithCapacity:self.zoneRules.count];
    for (CFFirewallAccessRule * rule in self.zoneRules) {
        if ([rule objectMatchesQuery:query]) {
            [self.filteredZoneRules addObject:rule];
        }
    }

    self.filteredGlobalRules = [NSMutableArray arrayWithCapacity:self.globalRules.count];
    for (CFFirewallAccessRule * rule in self.globalRules) {
        if ([rule objectMatchesQuery:query]) {
            [self.filteredGlobalRules addObject:rule];
        }
    }

    [self.tableView reloadData];
}

# pragma mark - Table view data source

# define section0Global(_s) _s == 0 && self->hasGlobalRules
# define section0Zone(_s) (_s == 0 && self->hasZoneRules) || _s == 1

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 0;
    if (hasZoneRules) {
        count ++;
    }
    if (hasGlobalRules) {
        count ++;
    }
    return count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section0Global(section)) {
        return self.parent.isSearching ? self.filteredGlobalRules.count : self.globalRules.count;
    } else if (section0Zone(section)) {
        return self.parent.isSearching ? self.filteredZoneRules.count : self.zoneRules.count;
    }

    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CFFirewallAccessRule * rule;

    if (self.parent.isSearching) {
        if (section0Global(indexPath.section)) {
            rule = [self.filteredGlobalRules objectAtIndex:indexPath.row];
        } else if (section0Zone(indexPath.section)) {
            rule = [self.filteredZoneRules objectAtIndex:indexPath.row];
        }
    } else {
        if (section0Global(indexPath.section)) {
            rule = [self.globalRules objectAtIndex:indexPath.row];
        } else if (section0Zone(indexPath.section)) {
            rule = [self.zoneRules objectAtIndex:indexPath.row];
        }
    }
    UITableViewCell * cell;
    if (rule.notes) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FirewallRule" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FirewallRuleNoNote" forIndexPath:indexPath];
    }


    UILabel * configLabel = (UILabel *)[cell viewWithTag:1];
    UILabel * noteLabel = (UILabel *)[cell viewWithTag:2];
    UILabel * actionLabel = (UILabel *)[cell viewWithTag:3];

    configLabel.text = rule.configuration.value;
    if (rule.configuration.target == FirewallAccessRuleConfigurationTargetCountry) {
        configLabel.text = l(format(@"Country::%@", rule.configuration.value));
    }

    if (rule.notes) {
        noteLabel.text = rule.notes;
    }
    actionLabel.text = l(format(@"FirewallAccessRuleMode::%@", [rule stringForMode]));

    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section0Global(section)) {
        return l(@"All Sites");
    } else if (section0Zone(section)) {
        return l(@"This Site");
    }

    return 0;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FirewallAccessRuleTableViewController * editView = [self.parent.storyboard instantiateViewControllerWithIdentifier:@"FirewallAccessRuleEdit"];
    CFFirewallAccessRule * rule;
    if (self.parent.isSearching) {
        if (section0Global(indexPath.section)) {
            rule = [self.filteredGlobalRules objectAtIndex:indexPath.row];
        } else if (section0Zone(indexPath.section)) {
            rule = [self.filteredZoneRules objectAtIndex:indexPath.row];
        }
    } else {
        if (section0Global(indexPath.section)) {
            rule = [self.globalRules objectAtIndex:indexPath.row];
        } else if (section0Zone(indexPath.section)) {
            rule = [self.zoneRules objectAtIndex:indexPath.row];
        }
    }
    [editView setRule:rule finished:^(CFFirewallAccessRule *rule, BOOL saved) {
        [self loadData];
    }];
    if (self.parent.isSearching) {
        [self.parent.searchController dismissViewControllerAnimated:NO completion:nil];
    }
    [self.parent.navigationController pushViewController:editView animated:YES];
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [uihelper
         presentConfirmInViewController:self.parent
         title:l(@"Are you sure you want to delete this rule?")
         body:l(@"This action cannot be undone without creating another rule.")
         confirmButtonTitle:l(@"Delete")
         cancelButtonTitle:l(@"Cancel")
         confirmActionIsDestructive:YES
         dismissed:^(BOOL confirmed) {
             if (confirmed) {
                 [authManager authenticateUserForChange:YES success:^{
                     CFFirewallAccessRule * rule;
                     if (section0Global(indexPath.section)) {
                         rule = [self.globalRules objectAtIndex:indexPath.row];
                     } else if (section0Zone(indexPath.section)) {
                         rule = [self.zoneRules objectAtIndex:indexPath.row];
                     }

                     [self.parent showProgressControl];
                     [api deleteFirewallAccessRule:currentZone rule:rule finished:^(BOOL success, NSError *error) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self.parent hideProgressControl];
                             [self.tableView endEditing:NO];
                         });
                         if (error) {
                             [uihelper
                              presentErrorInViewController:self.parent
                              error:error
                              dismissed:^(NSInteger buttonIndex) {
                                  [self loadData];
                              }];
                         } else {
                             [self loadData];
                         }
                     }];
                 } cancelled:nil];
             }
         }];
    }
}

@end
