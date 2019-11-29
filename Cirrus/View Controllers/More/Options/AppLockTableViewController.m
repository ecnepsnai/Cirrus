#import "AppLockTableViewController.h"

@interface AppLockTableViewController () {
    BOOL showChangeTypeCell;
}

@end

@implementation AppLockTableViewController

- (void) viewDidLoad {
    showChangeTypeCell = UserOptions.deviceLockChanges;
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return showChangeTypeCell ? 3 : 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;

    if (indexPath.row == 0 || indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];
        UILabel * label = [cell viewWithTag:1];
        UISwitch * toggle = [cell viewWithTag:2];
        if (indexPath.row == 0) {
            label.text = l(@"Using Cirrus");
            toggle.on = UserOptions.deviceLock;
            [toggle addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
                UserOptions.deviceLock = sender.on;
            }] forControlEvent:UIControlEventTouchUpInside];
        } else if (indexPath.row == 1) {
            label.text = l(@"Making Changes");
            toggle.on = UserOptions.deviceLockChanges;
            [toggle addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
                self->showChangeTypeCell = sender.on;
                UserOptions.deviceLockChanges = sender.on;

                [self.tableView beginUpdates];
                if (sender.on) {
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                } else {
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                [self.tableView endUpdates];
            }] forControlEvent:UIControlEventTouchUpInside];
        }
    } else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ChangeTypes" forIndexPath:indexPath];
        UILabel * label = [cell viewWithTag:1];
        UISegmentedControl * segment = [cell viewWithTag:2];
        label.text = l(@"Which Changes");
        [segment setTitle:l(@"All") forSegmentAtIndex:0];
        [segment setTitle:l(@"Dangerous") forSegmentAtIndex:1];
        if (UserOptions.deviceLockAllChanges) {
            [segment setSelectedSegmentIndex:0];
        } else {
            [segment setSelectedSegmentIndex:1];
        }
        [segment addSelector:[[OCSelector alloc] initWithBlock:^(UISegmentedControl * sender) {
            UserOptions.deviceLockAllChanges = sender.selectedSegmentIndex == 0;
        }] forControlEvent:UIControlEventValueChanged];
    }

    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [lang key:@"Require {authMode} when" args:@[OCAuthenticationManager.authenticationTypeString]];
}

@end
