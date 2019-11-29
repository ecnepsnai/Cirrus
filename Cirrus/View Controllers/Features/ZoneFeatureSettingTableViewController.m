#import "ZoneFeatureSettingTableViewController.h"
#import "OCZoneFeatureView.h"
#import "ZoneSSLFeatureView.h"
#import "ZoneFirewallFeatureView.h"
#import "ZoneCachingFeatureView.h"
#import "ZoneNetworkFeatureView.h"
#import "PurgeCacheTableViewController.h"

@interface ZoneFeatureSettingTableViewController ()

typedef NS_ENUM(NSInteger, ViewType) {
    ViewTypeSSL,
    ViewTypeNetwork,
    ViewTypeFirewall,
    ViewTypeCaching,
};

@property (strong, nonatomic) NSString * viewType;
@property (nonatomic) ViewType viewID;
@property (strong, nonatomic) NSDictionary<NSString *, CFZoneSettings *> * options;
@property (weak, nonatomic) UISegmentedControl * toggle;
@property (strong, nonatomic) GTAppLinks * appStoreHelper;
@property (strong, nonatomic) OCZoneFeatureView * featureView;

@end

@implementation ZoneFeatureSettingTableViewController

- (void) viewDidLoad {
    switch (self.viewID) {
        case ViewTypeSSL:
            self.featureView = [ZoneSSLFeatureView new];
            break;
        case ViewTypeNetwork:
            self.featureView = [ZoneNetworkFeatureView new];
            break;
        case ViewTypeFirewall:
            self.featureView = [ZoneFirewallFeatureView new];
            break;
        case ViewTypeCaching:
            self.featureView = [ZoneCachingFeatureView new];
            break;
    }
    self.featureView.options = self.options;
    self.featureView.controller = self;
    self.title = [self.featureView viewTitle];
    self.appStoreHelper = [GTAppLinks new];
    [super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) loadWithOptions:(NSDictionary<NSString *, CFZoneSettings *> *)options
                  ofType:(NSString *)type {
    _options = options;
    _viewType = type;
    
    if (nstrcmp(@"SSL", type)) {
        _viewID = ViewTypeSSL;
    } else if (nstrcmp(@"Network", type)) {
        _viewID = ViewTypeNetwork;
    } else if (nstrcmp(@"Firewall", type)) {
        _viewID = ViewTypeFirewall;
    } else if (nstrcmp(@"Caching", type)) {
        _viewID = ViewTypeCaching;
    }
}

- (void) applySetting:(CFZoneSettings *)setting {
    [self showProgressControl];
    [api applyZoneOptions:currentZone setting:setting finished:^(CFZoneSettings *setting, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressControl];
        });
        
        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:nil];
        }
    }];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PurgeCache"]) {
        PurgeCacheTableViewController * controller = segue.destinationViewController;
        controller.zone = currentZone;
    }
}

#pragma mark - Table view data source

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.featureView tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.featureView numberOfSectionsInTableView:tableView];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.featureView tableView:tableView numberOfRowsInSection:section];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.featureView tableView:tableView titleForHeaderInSection:section];
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [self.featureView tableView:tableView titleForFooterInSection:section];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.featureView tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
