#import "OptionsTableViewController.h"

@import LocalAuthentication;

@interface OptionsTableViewController ()

@property (weak, nonatomic) UISwitch * faviconSwitch;
@property (weak, nonatomic) UISwitch * touchIDSwitch;

@end

@implementation OptionsTableViewController

typedef NS_ENUM(NSUInteger, CellViewTags) {
    CellViewTagLabel = 10,
    CellViewTagToggle = 15,
    CellViewTagAuxLabel = 20
};

typedef NS_ENUM(NSInteger, TableSections) {
    SectionGeneral = 0,
    SectionDataProtection,
    SectionAccount,
};

static NSInteger numberOfSections = 3;
static const NSInteger rowsInSection[] = { 2, 1, 1 };
static const char * titlesForSection[] = { "General Settings", "App Security", "Account" };

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) closeButtonTapped:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return numberOfSections;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = rowsInSection[section];
    return rows;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return l([[NSString alloc] initWithUTF8String:titlesForSection[section]]);
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell;

    if (indexPath.section == SectionGeneral) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];
            UILabel * label = [cell viewWithTag:CellViewTagLabel];
            label.text = l(@"Show site favicons");
            self.faviconSwitch = [cell viewWithTag:CellViewTagToggle];
            self.faviconSwitch.on = UserOptions.showFavicons;
            [self.faviconSwitch addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
                UserOptions.showFavicons = sender.on;
                if (!sender.isOn) {
                    [[NSFileManager defaultManager] removeItemAtPath:FAVICON_DIRECTORY error:nil];
                    [[NSFileManager defaultManager] createDirectoryAtPath:FAVICON_DIRECTORY withIntermediateDirectories:NO attributes:nil error:nil];
                }
                notify(NOTIF_FAVICON_CHANGED);
            }] forControlEvent:UIControlEventTouchUpInside];
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
            UILabel * label = [cell viewWithTag:CellViewTagLabel];
            label.text = l(@"Hidden Zones");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (indexPath.section == SectionDataProtection) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
        UILabel * label = [cell viewWithTag:CellViewTagLabel];
        label.text = l(@"App Lock");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == SectionAccount) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = l(@"Manage Accounts");
        }
    }

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionGeneral && indexPath.row == 1) {
        [self performSegueWithIdentifier:@"HiddenZones" sender:nil];
    } else if (indexPath.section == SectionDataProtection && indexPath.row == 0) {
        [[OCAuthenticationManager sharedInstance] authenticateUserWithReason:l(@"Authenticate to access settings") success:^{
            [self performSegueWithIdentifier:@"AppLock" sender:nil];
        }];
    } else if (indexPath.section == SectionAccount && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"ShowEditAccounts" sender:nil];
    }
}

@end
