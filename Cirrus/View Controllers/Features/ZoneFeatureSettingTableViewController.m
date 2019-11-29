#import "ZoneFeatureSettingTableViewController.h"
#import "OCZoneFeatureView.h"
#import "ZoneSSLFeatureView.h"
#import "ZoneFirewallFeatureView.h"
#import "ZoneCachingFeatureView.h"
#import "ZoneNetworkFeatureView.h"
#import "PurgeCacheTableViewController.h"

@interface ZoneFeatureSettingTableViewController ()

@property (nonatomic) FeatureViewType viewType;
@property (strong, nonatomic) NSDictionary<NSString *, CFZoneSettings *> * options;
@property (weak, nonatomic) UISegmentedControl * toggle;
@property (strong, nonatomic) OCZoneFeatureView * featureView;
@property (nonatomic) BOOL showFeatureView;

@end

@implementation ZoneFeatureSettingTableViewController

- (void) viewDidLoad {
    switch (self.viewType) {
        case FeatureViewTypeSSL:
            self.featureView = [ZoneSSLFeatureView new];
            break;
        case FeatureViewTypeNetwork:
            self.featureView = [ZoneNetworkFeatureView new];
            break;
        case FeatureViewTypeSecurity:
            self.featureView = [ZoneFirewallFeatureView new];
            break;
        case FeatureViewTypeCaching:
            self.featureView = [ZoneCachingFeatureView new];
            break;
    }
    self.featureView.controller = self;
    self.title = [self.featureView viewTitle];
    [super viewDidLoad];
    [self loadData];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) setFeatureViewType:(FeatureViewType)type {
    self.viewType = type;
}

- (void) loadData {
    self.showFeatureView = NO;
    [self showProgressControl];
    [api getZoneOptions:currentZone finished:^(NSDictionary<NSString *, CFZoneSettings *> *objects, NSError *error) {
        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:^(NSInteger buttonIndex) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            return;
        }
        self.options = objects;
        self.featureView.options = self.options;
        self.showFeatureView = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressControl];
            [self.tableView reloadData];
        });
    }];
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
    if (!self.showFeatureView) {
        return 0;
    }

    return [self.featureView numberOfSectionsInTableView:tableView];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.showFeatureView) {
        return 0;
    }

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
