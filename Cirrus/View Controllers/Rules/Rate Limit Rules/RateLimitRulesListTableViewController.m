#import "RateLimitRulesListTableViewController.h"
#import "RateLimitRuleTableViewController.h"

@interface RateLimitRulesListTableViewController () {
    CFRateLimit * selectedRule;
}

@property (strong, nonatomic) NSArray<CFRateLimit *> * rules;
@property (strong, nonatomic) NSMutableArray<CFRateLimit *> * filteredRules;
@property (weak, nonatomic) UISearchController * searchController;

@end

@implementation RateLimitRulesListTableViewController

- (RateLimitRulesListTableViewController *) initWithParent:(RuleListViewController *)parent tableView:(UITableView *)tableView {
    self = [super init];

    self.parent = parent;
    self.tableView = tableView;
    self.rules = @[];
    [self loadData];
    self.searchController = self.parent.searchController;

    return self;
}

- (void) createNew {
    RateLimitRuleTableViewController * ruleTable = [self.parent.storyboard instantiateViewControllerWithIdentifier:@"EditRateLimitRule"];
    CFRateLimit * rule = [CFRateLimit ruleWithDefaults];
    [ruleTable setRule:rule finished:^(CFRateLimit * rule, BOOL saved) {
        [self loadData];
    }];
    [self.parent.navigationController pushViewController:ruleTable animated:YES];
}

- (void) loadData {
    [api getRateLimitsForZone:currentZone finished:^(NSArray<CFRateLimit *> *limits, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.parent.refreshControl endRefreshing];
        });

        if (error) {
            [uihelper presentErrorInViewController:self.parent error:error dismissed:nil];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.rules = limits;
                [self.tableView reloadData];
                if (self.rules.count == 0) {
                    [[OCTipManager sharedInstance] showTip:^(CMPopTipView * _Nonnull tip) {
                        tip.message = l(@"No rate limit rules. Tap here to create a new rule.");
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
    self.filteredRules = [NSMutableArray arrayWithCapacity:self.rules.count];
    for (CFRateLimit * rule in self.rules) {
        if ([rule objectMatchesQuery:query]) {
            [self.filteredRules addObject:rule];
        }
    }

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

# pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.parent.isSearching) {
        return self.filteredRules.count;
    } else {
        return self.rules.count;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RateLimit" forIndexPath:indexPath];
    CFRateLimit * rule;
    if (self.parent.isSearching) {
        rule = [self.filteredRules objectAtIndex:indexPath.row];
    } else {
        rule = [self.rules objectAtIndex:indexPath.row];
    }

    cell.textLabel.text = rule.comment ?: rule.match.request.url;
    cell.detailTextLabel.text = rule.ruleDescription;
    if (rule.enabled) {
        cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CFRateLimit * rule = [self.rules objectAtIndex:indexPath.row];
    RateLimitRuleTableViewController * ruleTable = [self.parent.storyboard instantiateViewControllerWithIdentifier:@"EditRateLimitRule"];
    [ruleTable setRule:rule finished:^(CFRateLimit * rule, BOOL saved) {
        [self loadData];
    }];
    if (self.parent.isSearching) {
        [self.parent.searchController dismissViewControllerAnimated:NO completion:nil];
    }
    [self.parent.navigationController pushViewController:ruleTable animated:YES];
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
                     CFRateLimit * rule;
                     if (self.parent.isSearching) {
                         rule = [self.filteredRules objectAtIndex:indexPath.row];
                     } else {
                         rule = [self.rules objectAtIndex:indexPath.row];
                     }

                     [self.parent showProgressControl];
                     [api deleteRateLimitForZone:currentZone limit:rule finished:^(BOOL success, NSError *error) {
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
