#import "PageRulesListTableViewController.h"
#import "PageRuleTableViewController.h"

@interface PageRulesListTableViewController () {
    CFPageRule * selectedRule;
    NSUInteger highestPriority;
    BOOL didReorder;
}

@property (strong, nonatomic) NSArray<CFPageRule *> * rules;
@property (strong, nonatomic) NSMutableArray<CFPageRule *> * filteredRules;
@property (strong, nonatomic) UISearchController * searchController;

@end

@implementation PageRulesListTableViewController

- (PageRulesListTableViewController *) initWithParent:(RuleListViewController *)parent tableView:(UITableView *)tableView {
    self = [super init];

    self.parent = parent;
    self.tableView = tableView;
    self.rules = @[];
    self.searchController = self.parent.searchController;
    [self loadData];
    return self;
}

- (void) createNew {
    if (self.rules.count > 0) {
        [uihelper
         presentActionSheetInViewController:self.parent
         attachToTarget:[ActionTipTarget targetWithBarButtonItem:self.parent.navigationItem.rightBarButtonItem]
         title:l(@"Add New Rule")
         subtitle:nil
         cancelButtonTitle:l(@"Cancel")
         items:@[l(@"At beginning"), l(@"At end")]
         dismissed:^(NSInteger itemIndex) {
             if (itemIndex != -1) {
                 CFPageRule * rule = [CFPageRule ruleWithDefaults];
                 if (itemIndex == 0) {
                     rule.priority = self->highestPriority + 1;
                 }
                 PageRuleTableViewController * ruleTable = [self.parent.storyboard instantiateViewControllerWithIdentifier:@"PageRuleEdit"];
                 [ruleTable setRule:rule finished:^(CFPageRule *rule, BOOL saved) {
                     [self loadData];
                 }];
                 [self.parent.navigationController pushViewController:ruleTable animated:YES];
             }
         }];
    } else {
        PageRuleTableViewController * ruleTable = [self.parent.storyboard instantiateViewControllerWithIdentifier:@"PageRuleEdit"];
        [ruleTable setRule:[CFPageRule ruleWithDefaults] finished:^(CFPageRule *rule, BOOL saved) {
            [self loadData];
        }];
        [self.parent.navigationController pushViewController:ruleTable animated:YES];
    }
}

- (void) loadData {
    [api getZonePageRules:currentZone finished:^(NSArray<CFPageRule *> *rules, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parent.refreshControl endRefreshing];
        });

        if (error) {
            [uihelper presentErrorInViewController:self.parent error:error dismissed:nil];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.rules = rules;
                for (CFPageRule * rule in self.rules) {
                    if (self->highestPriority < rule.priority) {
                        self->highestPriority = rule.priority;
                    }
                }

                [self.tableView reloadData];

                if (self.rules.count == 0) {
                    [[OCTipManager sharedInstance] showTip:^(CMPopTipView * _Nonnull tip) {
                        tip.message = l(@"No prage rules. Tap here to create new rule.");
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

- (void) updateReorder {
    
}

- (void) filterRules:(NSString *)query {
    self.filteredRules = [NSMutableArray arrayWithCapacity:self.rules.count];
    for (CFPageRule * rule in self.rules) {
        if ([rule objectMatchesQuery:query]) {
            [self.filteredRules addObject:rule];
        }
    }

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rules.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PageRule" forIndexPath:indexPath];
    CFPageRule * rule = [self.rules objectAtIndex:indexPath.row];
    cell.textLabel.text = rule.target;
    if (rule.enabled) {
        if (@available(iOS 13, *)) {
            cell.textLabel.textColor = [UIColor labelColor];
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
        }
    } else {
        if (@available(iOS 13, *)) {
            cell.textLabel.textColor = [UIColor secondaryLabelColor];
        } else {
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }
    }

    if (rule.actions.count == 1) {
        cell.detailTextLabel.text = [lang key:@"{count} action" args:@[[NSString stringWithFormat:@"%ld", (unsigned long)rule.actions.count]]];
    } else {
        cell.detailTextLabel.text = [lang key:@"{count} actions" args:@[[NSString stringWithFormat:@"%ld", (unsigned long)rule.actions.count]]];
    }
    cell.showsReorderControl = YES;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedRule = [self.rules objectAtIndex:indexPath.row];
    PageRuleTableViewController * ruleTable = [self.parent.storyboard instantiateViewControllerWithIdentifier:@"PageRuleEdit"];
    [ruleTable setRule:selectedRule finished:^(CFPageRule *rule, BOOL saved) {
        [self loadData];
    }];
    if (self.parent.isSearching) {
        [self.parent.searchController dismissViewControllerAnimated:NO completion:nil];
    }
    [self.parent.navigationController pushViewController:ruleTable animated:YES];
}

- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray<CFPageRule *> * newRules = [NSMutableArray arrayWithArray:self.rules];
    CFPageRule * rule = [newRules objectAtIndex:sourceIndexPath.row];
    [newRules removeObjectAtIndex:sourceIndexPath.row];
    [newRules insertObject:rule atIndex:destinationIndexPath.row];
    self.rules = newRules;
    didReorder = YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [uihelper
         presentConfirmInViewController:self.parent
         title:l(@"Are you sure you want to delete this page rule?")
         body:l(@"This action cannot be undone without creating another rule.")
         confirmButtonTitle:l(@"Delete")
         cancelButtonTitle:l(@"Cancel")
         confirmActionIsDestructive:YES
         dismissed:^(BOOL confirmed) {
             if (confirmed) {
                 [authManager authenticateUserForChange:YES success:^{
                     CFPageRule * ruleToDelete = [self.rules objectAtIndex:indexPath.row];
                     [self.parent showProgressControl];
                     [api deleteZonePageRule:currentZone rule:ruleToDelete finished:^(BOOL success, NSError *error) {
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

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [self.parent setEditing:editing animated:animated];
    if (!editing && didReorder) { // Done
        didReorder = NO;
        NSUInteger priority = self.rules.count;
        NSUInteger __block rulesUpdated = 0;
        [self.parent showProgressControl];
        for (CFPageRule * rule in self.rules) {
            rule.priority = priority;
            priority --;
            [api updateZonePageRule:currentZone rule:rule finished:^(BOOL success, NSError *error) {
                rulesUpdated ++;
                
                if (rulesUpdated == self.rules.count - 1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.parent hideProgressControl];
                        [self loadData];
                    });
                }
            }];
        }
    }
}

@end
