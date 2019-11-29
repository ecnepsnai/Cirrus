#import "ZoneSettingsTableViewController.h"
#import "ZoneFeatureSettingTableViewController.h"

@interface ZoneSettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *switchDevelopmentMode;
@property (weak, nonatomic) IBOutlet UISwitch *switchPauseSite;
@property (weak, nonatomic) IBOutlet UISwitch *switchAttack;
@property (weak, nonatomic) IBOutlet UISwitch *switchAlwaysOnline;

@property (strong, nonatomic) NSDictionary<NSString *, CFZoneSettings *> * settings;

@end

@implementation ZoneSettingsTableViewController

typedef NS_ENUM(NSInteger, SwitchTag) {
    SwitchTagDevelopmentMode = 10,
    SwitchTagPauseSite = 11,
    SwitchTagAttack = 12,
    SwitchTagAlwaysOnline = 13
};

- (void) viewDidLoad {
    self.switchAttack.onTintColor = [UIColor materialRed];
    self.switchDevelopmentMode.onTintColor = [UIColor materialAmber];

    self.switchPauseSite.on = currentZone.paused;
    self.switchDevelopmentMode.on = currentZone.development_mode > 0;
    [self addZoneMenuButtonWithTitle:l(@"Site Settings & Features")];

    subscribe(@selector(zoneChanged:), NOTIF_ZONE_CHANGED);
    [self loadData];

    [super viewDidLoad];
}

- (void) zoneChanged:(NSNotification *)n {
    [self loadData];
}

- (void) loadData {
    [self showProgressControl];
    [api getZoneOptions:currentZone finished:^(NSDictionary<NSString *, CFZoneSettings *> *objects, NSError *error) {
        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:^(NSInteger buttonIndex) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            return;
        }
        self.settings = objects;

        CFZoneSettings * alwaysOnlineSetting = [objects objectForKey:@"always_online"];
        CFZoneSettings * firewallSettings = [objects objectForKey:@"security_level"];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.switchAlwaysOnline.on = nstrcmp(alwaysOnlineSetting.value, @"on");
            self.switchAttack.on = nstrcmp(firewallSettings.value, @"under_attack");
            [self hideProgressControl];
        });
    }];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) switchChange:(UISwitch *)sender {
    switch (sender.tag) {
        case SwitchTagDevelopmentMode: {
            [authManager authenticateUserForChange:NO success:^{
                CFZoneSettings * setting = [self.settings objectForKey:@"development_mode"];
                setting.value = sender.on ? @"on" : @"off";
                [self changeSettingValue:setting];
            } cancelled:^{
                [sender setOn:!sender.on animated:YES];
            }];
            break;
        }
        case SwitchTagPauseSite: {
            [authManager authenticateUserForChange:NO success:^{
                [self showProgressControl];
                self.view.userInteractionEnabled = NO;
                [api setPauseForZone:currentZone paused:sender.on finished:^(BOOL success, NSError *error) {
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
            break;
        }
        case SwitchTagAttack: {
            [authManager authenticateUserForChange:NO success:^{
                CFZoneSettings * firewallSettings = [self.settings objectForKey:@"security_level"];
                firewallSettings.value = sender.on ? @"under_attack" : @"medium";
                [self changeSettingValue:firewallSettings];
            } cancelled:^{
                [sender setOn:!sender.on animated:YES];
            }];
            break;
        }
        case SwitchTagAlwaysOnline: {
            [authManager authenticateUserForChange:NO success:^{
                CFZoneSettings * setting = [self.settings objectForKey:@"always_online"];
                setting.value = sender.on ? @"on" : @"off";
                [self changeSettingValue:setting];
            } cancelled:^{
                [sender setOn:!sender.on animated:YES];
            }];
            break;
        }
    }
}

- (void) changeSettingValue:(CFZoneSettings *)setting {
    [self showProgressControl];
    self.view.userInteractionEnabled = NO;
    [api applyZoneOptions:currentZone setting:setting finished:^(CFZoneSettings * setting, NSError *error) {
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
                    currentZone.development_mode = 1;
                } else {
                    currentZone.development_mode = 0;
                }
            }
        }
    }];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier hasPrefix:@"Feature"]) {
        NSString * type;
        if (nstrcmp(@"FeatureSSL", segue.identifier)) {
            type = @"SSL";
        } else if (nstrcmp(@"FeatureNetwork", segue.identifier)) {
            type = @"Network";
        } else if (nstrcmp(@"FeatureFirewall", segue.identifier)) {
            type = @"Firewall";
        } else if (nstrcmp(@"FeatureCaching", segue.identifier)) {
            type = @"Caching";
        }

        [(ZoneFeatureSettingTableViewController *)[segue destinationViewController]
         loadWithOptions:self.settings ofType:type];
    }
}

@end
