#import "AboutTableViewController.h"

@interface AboutTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) GTAppLinks * appLinks;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AboutTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.appLinks = [GTAppLinks forApp:GTAppCirrus];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Table View Datasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 2;
        case 2:
            return 1;
    }

    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return l(@"Get Support");
        case 2:
            return l(@"Legal");
    }

    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 1: {
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
            NSString * appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
#if TESTFLIGHT_BUILD
            appVersion = nstrcat(appVersion, @" TestFlight");
#endif
            NSNumber * build = [infoDict objectForKey:@"CFBundleVersion"];
            NSString * appBuild = [NSString stringWithFormat:@"%i", [build intValue]];
            return format(@"%@ (%@)", appVersion, appBuild);
        } case 2: {
            return l(@"Cirrus was created by Ian Spence. Copyright © Ian Spence 2016. All rights reserved. Cirrus is in no way affiliated or endorsed by Cloudflare.");
        }
    }

    return nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];

    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = l(@"Cirrus Support");
                    break;
                case 1:
                    cell.textLabel.text = l(@"Cloudflare Support");
                    break;
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = l(@"Rate Cirrus");
                    break;
                case 1:
                    cell.textLabel.text = l(@"Test New Features");
                    break;
            }
            break;
        }
        case 2: {
            cell.textLabel.text = l(@"Acknowledgments");
            break;
        }
    }

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.appLinks showEmailComposeSheetInViewController:self dismissed:nil];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://support.cloudflare.com/"]];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self.appLinks showAppStorePageInViewController:self dismissed:nil];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://cirrus-app.com/beta.html"]];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://cirrus-app.com/acknowledgements.html"]];
    }
}

- (IBAction) closeButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
