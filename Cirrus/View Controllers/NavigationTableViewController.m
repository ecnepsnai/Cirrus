#import "NavigationTableViewController.h"
#import "FontAwesome.h"
#import "NavigationTableViewSection.h"

@interface NavigationTableViewController () {
    BOOL initialDraw;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (strong, nonatomic) NSArray<NavigationTableViewSection *> * sections;
@end

@implementation NavigationTableViewController

- (void) viewDidLoad {
    self.sections = @[
        [NavigationTableViewSection sectionWithTitle:@"DNS" cells:@[
            [NavigationTableViewCell cellWithTitle:@"Records" icon:FAFileAltLight storyboardName:STORYBOARD_DNS viewControllerIdentifier:@"DNS"],
            [NavigationTableViewCell cellWithTitle:@"Domain Registration" icon:FAAtlasLight storyboardName:STORYBOARD_DOMAIN_REGISTRATION viewControllerIdentifier:@"Registration"]
        ]],
        [NavigationTableViewSection sectionWithTitle:@"Analytics" cells:@[
            [NavigationTableViewCell cellWithTitle:@"Traffic" icon:FAChartBarLight storyboardName:STORYBOARD_ANALYTICS viewControllerIdentifier:@"Traffic"],
            [NavigationTableViewCell cellWithTitle:@"Security" icon:FAShieldLight storyboardName:STORYBOARD_ANALYTICS viewControllerIdentifier:@"Security"],
            [NavigationTableViewCell cellWithTitle:@"Performance" icon:FARabbitFastLight storyboardName:STORYBOARD_ANALYTICS viewControllerIdentifier:@"Performance"],
            [NavigationTableViewCell cellWithTitle:@"DNS" icon:FAChartLineLight storyboardName:STORYBOARD_ANALYTICS viewControllerIdentifier:@"DNS"],
            [NavigationTableViewCell cellWithTitle:@"Workers" icon:FAMicrochipLight storyboardName:STORYBOARD_ANALYTICS viewControllerIdentifier:@"Workers"],
        ]],
        [NavigationTableViewSection sectionWithTitle:@"Rules" cells:@[
            [NavigationTableViewCell cellWithTitle:@"Page Rules" icon:FAFileLight storyboardName:STORYBOARD_RULES viewControllerIdentifier:@"Page"],
            [NavigationTableViewCell cellWithTitle:@"IP Firewall" icon:FAGlobeLight storyboardName:STORYBOARD_RULES viewControllerIdentifier:@"IPFirewall"],
            [NavigationTableViewCell cellWithTitle:@"Rate Limit" icon:FATachometerLight storyboardName:STORYBOARD_RULES viewControllerIdentifier:@"RateLimit"],
            [NavigationTableViewCell cellWithTitle:@"Web Application" icon:FACloudLight storyboardName:STORYBOARD_RULES viewControllerIdentifier:@"WAF"],
        ]],
        [NavigationTableViewSection sectionWithTitle:@"Features" cells:@[
            [NavigationTableViewCell cellWithTitle:@"TLS" icon:FALockLight storyboardName:STORYBOARD_FEATURES viewControllerIdentifier:@"TLS"],
            [NavigationTableViewCell cellWithTitle:@"Network" icon:FANetworkWiredLight storyboardName:STORYBOARD_FEATURES viewControllerIdentifier:@"Network"],
            [NavigationTableViewCell cellWithTitle:@"Security Level" icon:FAExclamationTriangleLight storyboardName:STORYBOARD_FEATURES viewControllerIdentifier:@"Security"],
            [NavigationTableViewCell cellWithTitle:@"Caching" icon:FAHddLight storyboardName:STORYBOARD_FEATURES viewControllerIdentifier:@"Caching"],
            [NavigationTableViewCell cellWithTitle:@"HSTS" icon:FABadgeCheckLight storyboardName:STORYBOARD_FEATURES viewControllerIdentifier:@"HSTS"],
        ]],
    ];
    [super viewDidLoad];
    self.title = currentZone.name;
}

- (IBAction) closeButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!initialDraw && isSplitSideBySide && indexPath.row == 0 && indexPath.section == 0) {
        [cell setSelected:YES];
        initialDraw = YES;
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].cells.count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].title;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Icon" forIndexPath:indexPath];
    [self.sections[indexPath.section].cells[indexPath.row] formatCell:cell];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController * controller = [self.sections[indexPath.section].cells[indexPath.row] viewController];
    [appState.splitViewController showDetailViewController:controller sender:self];
}

@end
