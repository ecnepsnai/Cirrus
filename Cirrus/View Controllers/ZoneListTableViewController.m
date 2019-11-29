#import "ZoneListTableViewController.h"
#import "LoginWebViewController.h"
#import "OCZoneFaviconManager.h"
#import "OCZoneLoader.h"
#import "AppLinks.h"

@import LocalAuthentication;

@interface ZoneListTableViewController () <UITableViewDelegate, RefreshSearchTableViewDelegate> {
    BOOL keyLoaded;
}

@property (strong, nonatomic) NSArray<CFZone *> * sites;
@property (strong, nonatomic) NSMutableArray<CFZone *> * filteredSites;

@property (strong, nonatomic) NSMutableDictionary<NSString *, UIImage *> * favicons;
@property (strong, nonatomic) NSMutableDictionary<NSString *, UIImageView *> * faviconViews;

@end

@implementation ZoneListTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    
    appState.zoneListViewController = self;

    self.favicons = [NSMutableDictionary new];
    self.faviconViews = [NSMutableDictionary new];
    keyLoaded = NO;
    [appState firstRun:self finished:^(NSError * error) {
        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:nil];
        } else {
            [self triggerLoadOfSites];
        }
    }];

    subscribe(@selector(reloadData), NOTIF_RELOAD_ZONES);
}

- (void) userPulledToRefresh {
    [self getZones];
}

- (void) reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl beginRefreshing];
        [self getZones];
    });
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) triggerLoadOfSites {
#if !defined(DEBUG) && !TESTFLIGHT_BUILD
    [[AppLinks new] appLaunchRate];
#endif
    [self getZones];
}

- (void) getZones {
    [OCZoneLoader.sharedInstance loadAllZones:^(NSArray<CFZone *> *zones, NSError *error) {
        [self.refreshControl endRefreshing];

        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:nil];
            return;
        }

        if (zones.count > 0) {
            currentZone = zones[0];
            UITableViewCell * firstZone = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [[OCTipManager sharedInstance] showTipWithIdentifier:TIP_ZONE_OPTIONS configuration:^(CMPopTipView *tip) {
                tip.message = l(@"Press & Hold on a zone for more options");
                [tip presentPointingAtView:firstZone inView:self.view animated:YES];
            }];
        }
        self.sites = zones;
        [self.tableView reloadData];
    }];
}

# pragma mark - Search View

- (void) userDidSearch:(NSString *)query {
    [self filterZones:query];
}

- (void) filterZones:(NSString *)query {
    self.filteredSites = [NSMutableArray arrayWithCapacity:self.sites.count];
    for (CFZone * zone in self.sites) {
        NSString * name = [zone.name lowercaseString];
        NSString * search = [query lowercaseString];
        if ([name containsString:search]) {
            [self.filteredSites addObject:zone];
        }
    }

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isSearching ? self.filteredSites.count : self.sites.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZoneTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Zone" forIndexPath:indexPath];

    CFZone * zone;
    if (self.isSearching) {
        zone = self.filteredSites[indexPath.row];
    } else {
        zone = self.sites[indexPath.row];
    }

    [cell configureCellForZone:zone onController:self];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    currentZone = self.isSearching ? self.filteredSites[indexPath.row] : self.sites[indexPath.row];
    d(@"Current zone %@", currentZone.name);

    OCSplitViewController * splitController = [self.storyboard instantiateViewControllerWithIdentifier:@"Split"];
    splitController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:splitController animated:YES completion:nil];
}

- (void) disableTableView {
    self.tableView.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.searchController.searchBar.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.alpha = 0.75;
    }];
}

- (void) enableTableView {
    self.tableView.userInteractionEnabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.searchController.searchBar.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.alpha = 1.0;
    }];
}

@end
