#import "ManageAccountsTableViewController.h"
#import "LoginWebViewController.h"
#import "LoginTableViewController.h"

@interface ManageAccountsTableViewController () {
    short didSignOut;
}

@property (strong, nonatomic) NSArray<CFCredentials *> * credentials;

@end

@implementation ManageAccountsTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.credentials = CFCredentialManager.sharedInstance.allCredentials;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showCloseMessage];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.credentials.count;
    } else if (section == 1) {
        return 2;
    }

    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return l(@"Accounts");
    }
    return nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;

    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"User" forIndexPath:indexPath];
        cell.textLabel.text = self.credentials[indexPath.row].email;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"AddAccount" forIndexPath:indexPath];
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SignOut" forIndexPath:indexPath];
        }
    }

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [uihelper
             presentActionSheetInViewController:self
             attachToTarget:[ActionTipTarget targetWithView:[tableView cellForRowAtIndexPath:indexPath]]
             title:l(@"Add Account")
             subtitle:nil
             cancelButtonTitle:l(@"Cancel")
             items:@[
                     l(@"Login using Email & API Key"),
                     l(@"Login using Email & Password")
                     ]
             dismissed:^(NSInteger itemIndex) {
                 if (itemIndex == 0) {
                     LoginTableViewController * loginController = viewControllerFromStoryboard(STORYBOARD_MAIN, @"Login");
                     loginController.addAdditionalAccount = YES;
                     [loginController performLogin:self finished:^(NSError * error, CFCredentials * key) {
                         if (error) {
                             [uihelper presentErrorInViewController:self error:error dismissed:nil];
                         } else if (key) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 self.credentials = CFCredentialManager.sharedInstance.allCredentials;
                                 [self.tableView reloadData];
                             });
                         }
                     }];
                 } else if (itemIndex == 1) {
                     LoginWebViewController * loginController = viewControllerFromStoryboard(STORYBOARD_MAIN, @"Login Web");
                     loginController.addAdditionalAccount = YES;
                     [loginController performLogin:self finished:^(NSError * error, CFCredentials * key) {
                         if (error) {
                             [uihelper presentErrorInViewController:self error:error dismissed:nil];
                         } else if (key) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 self.credentials = CFCredentialManager.sharedInstance.allCredentials;
                                 [self.tableView reloadData];
                             });
                         }
                     }];
                 }
            }];
        } else if (indexPath.row == 1) {
            [uihelper
             presentConfirmInViewController:self
             title:l(@"Are you sure?")
             body:l(@"This will completely remove your credentials from the device.")
             confirmButtonTitle:l(@"Yes")
             cancelButtonTitle:l(@"No")
             confirmActionIsDestructive:YES
             dismissed:^(BOOL confirmed) {
                 if (confirmed) {
                     [keyManager removeAllAccountsFromStorage];
                     self->didSignOut = 1;
                     [self showCloseMessage];
                 }
             }];
        }
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return l(@"Sign Out");
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [uihelper
         presentConfirmInViewController:self
         title:l(@"Are you sure you want to sign out from this account?")
         body:l(@"You will no longer have access to the zones on this account.")
         confirmButtonTitle:l(@"Sign Out")
         cancelButtonTitle:l(@"Cancel")
         confirmActionIsDestructive:YES
         dismissed:^(BOOL confirmed) {
             if (confirmed) {
                 [CFCredentialManager.sharedInstance forgetCredentials:self.credentials[indexPath.row]];
                 self.credentials = CFCredentialManager.sharedInstance.allCredentials;
                 [self.tableView reloadData];
             }
         }];
    }
}

- (void) addAccount {

}

- (void) showCloseMessage {
    if (didSignOut) {
        UIAlertController * alertController = [UIAlertController
                                               alertControllerWithTitle:l(@"Close Cirrus")
                                               message:l(@"close_app_description")
                                               preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:NO completion:nil];
    }
}

@end
