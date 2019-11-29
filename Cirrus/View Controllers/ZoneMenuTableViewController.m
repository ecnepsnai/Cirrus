#import "ZoneMenuTableViewController.h"
#import "PurgeCacheTableViewController.h"

@interface ZoneMenuTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *pauseWebsiteSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *devModeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *attackSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *readOnlySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *hiddenSwitch;
@property (strong, nonatomic) void (^finished)(void);
@property (strong, nonatomic) CFZone * zone;
@property (strong, nonatomic) NSDictionary<NSString *, CFZoneSettings *> * settings;

@end

@implementation ZoneMenuTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.title = self.zone.name;

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getOptions) forControlEvents:UIControlEventValueChanged];

    [self getOptions];
}

- (void) getOptions {
    [self.refreshControl beginRefreshing];
    [api getZoneOptions:self.zone finished:^(NSDictionary<NSString *,CFZoneSettings *> *objects, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });

        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:nil];
            return;
        }

        self.settings = objects;

        dispatch_async(dispatch_get_main_queue(), ^{
            self.devModeSwitch.on = self.zone.development_mode > 0;
            self.pauseWebsiteSwitch.on = self.zone.paused;
            NSString * securityLevel = objects[@"security_level"].value;
            self.attackSwitch.on = [securityLevel isEqualToString:@"under_attack"];
            self.readOnlySwitch.on = isZoneReadonly(self.zone);
            self.hiddenSwitch.on = self.zone.hidden;
            [self enableDisableSwitches];
        });
    }];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) showZoneMenuOnController:(UIViewController *)controller forZone:(CFZone *)zone finished:(void (^)(void))finished {
    self.finished = finished;
    self.zone = zone;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    [controller presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction) doneButton:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        self.finished();
    }];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        [self purgeZoneCahceTarget:[tableView cellForRowAtIndexPath:indexPath]];
    } else if (indexPath.section == 3) {
        [self deleteZone];
    }
}

- (void) purgeZoneCahceTarget:(UITableViewCell *)cell {
    PurgeCacheTableViewController * purgeController = viewControllerFromStoryboard(STORYBOARD_FEATURES, @"PurgeCache");
    purgeController.zone = self.zone;
    purgeController.showDoneButton = YES;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:purgeController] animated:YES completion:nil];
}

- (void) deleteZone {
    [uihelper
     presentConfirmInViewController:self
     title:[lang key:@"Delete {zone_name}?" args:@[self.zone.name]]
     body:l(@"This action is permanent and your settings will not be saved.")
     confirmButtonTitle:l(@"Delete")
     cancelButtonTitle:l(@"Keep")
     confirmActionIsDestructive:YES
     dismissed:^(BOOL confirmed) {
         if (confirmed) {
             [authManager authenticateUserForChange:YES success:^{
                 [api deleteZone:self.zone finished:^(BOOL success, NSError *error) {
                     if (error) {
                         [uihelper presentErrorInViewController:self error:error dismissed:nil];
                     }
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self doneButton:nil];
                     });
                 }];
             } cancelled:nil];
         }
     }];
}

- (void) changeSettingValue:(CFZoneSettings *)setting {
    [self showProgressControl];
    self.view.userInteractionEnabled = NO;
    [api applyZoneOptions:self.zone setting:setting finished:^(CFZoneSettings * setting, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressControl];
            self.view.userInteractionEnabled = YES;
        });

        notify(NOTIF_RELOAD_ZONES);

        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:nil];
        } else {
            if ([setting.name isEqualToString:@"development_mode"]) {
                if ([setting.value isEqualToString:@"on"]) {
                    self.zone.development_mode = 1;
                } else {
                    self.zone.development_mode = 0;
                }
            }
        }
    }];
}

- (IBAction) pauseWebsite:(UISwitch *)sender {
    [authManager authenticateUserForChange:NO success:^{
        [self showProgressControl];
        self.view.userInteractionEnabled = NO;
        [api setPauseForZone:self.zone paused:sender.on finished:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgressControl];
                self.view.userInteractionEnabled = YES;
            });

            if (error) {
                [uihelper presentErrorInViewController:self error:error dismissed:nil];
            }
        }];
    } cancelled:^{
        [sender setOn:!sender.on animated:YES];
    }];
}

- (IBAction) devMode:(UISwitch *)sender {
    [authManager authenticateUserForChange:NO success:^{
        CFZoneSettings * setting = [self.settings objectForKey:@"development_mode"];
        setting.value = sender.on ? @"on" : @"off";
        [self changeSettingValue:setting];
    } cancelled:^{
        [sender setOn:!sender.on animated:YES];
    }];
}

- (IBAction) attack:(UISwitch *)sender {
    [authManager authenticateUserForChange:NO success:^{
        CFZoneSettings * firewallSettings = [self.settings objectForKey:@"security_level"];
        firewallSettings.value = sender.on ? @"under_attack" : @"medium";
        [self changeSettingValue:firewallSettings];
    } cancelled:^{
        [sender setOn:!sender.on animated:YES];
    }];
}

- (IBAction) readOnly:(UISwitch *)sender {
    [authManager authenticateUserForChange:YES success:^{
        if (sender.isOn) {
            [[OCReadOnlyZoneManager sharedInstance] markZoneAsReadOnly:self.zone];
        } else {
            [[OCReadOnlyZoneManager sharedInstance] markZoneAdReadWrite:self.zone];
        }
        [self enableDisableSwitches];
    } cancelled:^{
        sender.on = YES;
    }];
}

- (void) enableDisableSwitches {
    BOOL enabled = !isZoneReadonly(self.zone);
    self.pauseWebsiteSwitch.enabled = enabled;
    self.devModeSwitch.enabled = enabled;
    self.attackSwitch.enabled = enabled;
}

- (IBAction) hidden:(UISwitch *)sender {
    self.zone.hidden = sender.on;
}

@end
