#import "AboutTableViewController.h"
#import "OCGradientView.h"
#import "AppLinks.h"

@interface AboutTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) AppLinks * appLinks;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet OCGradientView *gradientView;
@property (weak, nonatomic) IBOutlet UILabel *cloudIcon;

@end

@implementation AboutTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.appLinks = [AppLinks new];
    [self setNeedsStatusBarAppearanceUpdate];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnCloud)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.cloudIcon addGestureRecognizer:tapGestureRecognizer];
    self.cloudIcon.userInteractionEnabled = YES;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor *) randomColor {
    CGFloat red = arc4random_uniform(256) / 255.0;
    CGFloat green = arc4random_uniform(256) / 255.0;
    CGFloat blue = arc4random_uniform(256) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

- (void) didTapOnCloud {
    self.gradientView.firstColor = [self randomColor];
    self.gradientView.secondColor = [self randomColor];
    [self.gradientView drawRect:self.gradientView.bounds];
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
            return format(@"%@ (%@ - %@)", appVersion, appBuild, GIT_REVISION);
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
        [self.appLinks showEmailComposeSheetForAppInViewController:self withComments:nil dismissed:nil];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        open_url(@"https://support.cloudflare.com/");
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self.appLinks showAppInAppStorInViewController:self dismissed:nil];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        open_url(@"https://cirrus-app.com/beta.html");
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        open_url(@"https://cirrus-app.com/acknowledgements.html");
    }
}

- (IBAction) closeButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
