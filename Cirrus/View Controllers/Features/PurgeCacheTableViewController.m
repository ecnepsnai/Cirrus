#import "PurgeCacheTableViewController.h"

@interface PurgeCacheTableViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray<NSString *> * recentlyPurgeURLs;

@end

@implementation PurgeCacheTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    NSDictionary<NSString *, NSArray <NSString *> *> * recentlyPurgedCollection = UserOptions.recentlyPurgedURLs;
    if (!recentlyPurgedCollection) {
        recentlyPurgedCollection = [NSDictionary new];
    }
    NSArray<NSString *> * recentURLs = [recentlyPurgedCollection arrayForKey:self.zone.name];
    if (!recentURLs) {
        recentURLs = [NSArray new];
    }
    self.recentlyPurgeURLs = [NSMutableArray arrayWithArray:recentURLs];

    if (self.showDoneButton) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeView)];
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) closeView {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) syncRecentlyPurgedURLs {
    NSDictionary<NSString *, NSArray <NSString *> *> * recentlyPurgedCollection = UserOptions.recentlyPurgedURLs;
    if (!recentlyPurgedCollection) {
        recentlyPurgedCollection = [NSDictionary new];
    }
    NSMutableDictionary * updatedCollection = [NSMutableDictionary dictionaryWithDictionary:recentlyPurgedCollection];
    updatedCollection[self.zone.name] = self.recentlyPurgeURLs;
    UserOptions.recentlyPurgedURLs = updatedCollection;
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1 + self.recentlyPurgeURLs.count;
    }

    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return l(@"Individual Files");
    }

    return nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;

    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Button" forIndexPath:indexPath];
        cell.textLabel.text = l(@"Purge Entire Website");
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Input" forIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
            cell.textLabel.text = self.recentlyPurgeURLs[indexPath.row-1];
        }
    }

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self showProgressControl];
        [api purgeAllCacheForZone:self.zone finished:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView deselectRowAtIndexPath:indexPath animated:true];
            });
            [self hideProgressControl];
            if (error) {
                [uihelper presentErrorInViewController:self error:error dismissed:nil];
            } else {
                [self showDoneHUD];
            }
        }];
    } else if (indexPath.section == 1 && indexPath.row > 0) {
        [self showProgressControl];
        [api purgeFilesCacheForZone:self.zone files:@[self.recentlyPurgeURLs[indexPath.row-1]] finished:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView deselectRowAtIndexPath:indexPath animated:true];
            });
            [self hideProgressControl];
            if (error) {
                [uihelper presentErrorInViewController:self error:error dismissed:nil];
            } else {
                [self showDoneHUD];
            }
        }];
    }
}

- (void) showDoneHUD {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = l(@"Done");

        [hud hideAnimated:YES afterDelay:1.f];
    });
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.text.length == 0) {
        textField.text = format(@"https://%@/", self.zone.name);
    };
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self purgeURL:textField.text];
    [textField resignFirstResponder];
    return YES;
}

- (void) purgeURL:(NSString *)url {
    [self showProgressControl];
    [api purgeFilesCacheForZone:self.zone files:@[url] finished:^(BOOL success, NSError *error) {
        [self hideProgressControl];
        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:nil];
        } else {
            [self showDoneHUD];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.recentlyPurgeURLs addObject:url];
                [self syncRecentlyPurgedURLs];
                [self.tableView reloadData];
            });
        }
    }];
}

@end
