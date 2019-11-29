#import "HSTSSettingsTableViewController.h"
#import "ToggleTableViewCell.h"

@interface HSTSSettingsTableViewController () {
    NSArray<NSNumber *> * ageValues;
    NSArray<NSString *> * ageTitles;
}

@property (strong, nonatomic) CFHSTSSettings * settings;
@property (strong, nonatomic) OCSelector * saveAction;
@property (strong, nonatomic) OCSelector * cancelAction;

@end

@implementation HSTSSettingsTableViewController

typedef NS_ENUM(NSUInteger, HSTSSections) {
    SectionEnable = 0,
    SectionMaxAge,
    SectionSubdomain,
    SectionPreload,
    SectionNosniff,
    SectionMax
};

- (void) viewDidLoad {
    [super viewDidLoad];
    [self showProgressControl];
    [api getHSTSSettingsForZone:currentZone finished:^(CFHSTSSettings *settings, NSError *error) {
        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:nil];
        } else {
            self.settings = settings;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        [self hideProgressControl];
    }];

    ageValues = @[
                  @0,
                  @2592000,
                  @5184000,
                  @7776000,
                  @10368000,
                  @12960000,
                  @15552000,
                  @31536000
                  ];
    ageTitles = @[
                  l(@"Disabled"),
                  l(@"1 month"),
                  l(@"2 months"),
                  l(@"3 months"),
                  l(@"4 months"),
                  l(@"5 months"),
                  l(@"6 months"),
                  l(@"12 months")
                  ];

    self.saveAction = [[OCSelector alloc] initWithBlock:^(id sender) {
        [authManager authenticateUserForChange:YES success:^{
            [self showProgressControl];
            [api setHSTSSettingsForZone:currentZone settings:self.settings finished:^(BOOL success, NSError *error) {
                [self hideProgressControl];
                if (error) {
                    [uihelper presentErrorInViewController:self error:error dismissed:nil];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self restoreViewFromSave];
                    });
                }
            }];
        } cancelled:nil];
    }];

    self.cancelAction = [[OCSelector alloc] initWithBlock:^(id sender) {
        [self restoreViewFromSave];
    }];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case SectionEnable:
            return l(@"Instruct browsers to only use HTTPS for this domain.");
        case SectionMaxAge:
            return l(@"How long browser should cache the HSTS setting.");
        case SectionSubdomain:
            return l(@"Include all subdomains in the HSTS policy.");
        case SectionPreload:
            return l(@"Permit browsers to preload HSTS settings.");
        case SectionNosniff:
            return l(@"Prevent browsers from MIME-sniffing away from the declared Content-Type.");
    }

    return nil;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settings.enabled ? SectionMax : 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionEnable: {
            ToggleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];
            cell.titleLabel.text = l(@"Enable HSTS");
            cell.toggle.on = self.settings.enabled;
            [cell.toggle addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
                self.settings.enabled = sender.on;
                [self.tableView reloadData];
                [self updateViewForSave:self.saveAction confirmSave:YES cancelAction:self.cancelAction confirmCancel:YES];
            }] forControlEvent:UIControlEventTouchUpInside];
            return cell;
        }
        case SectionMaxAge: {
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetail" forIndexPath:indexPath];
            cell.textLabel.text = l(@"Maximum Age");
            cell.detailTextLabel.text = l([ageTitles objectAtIndex:[ageValues indexOfObject:[NSNumber numberWithUnsignedInteger:self.settings.max_age]]]);
            return cell;
        }
        case SectionSubdomain: {
            ToggleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];
            cell.titleLabel.text = l(@"Include Subdomains");
            cell.toggle.on = self.settings.include_subdomains;
            [cell.toggle addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
                self.settings.include_subdomains = sender.on;
                [self updateViewForSave:self.saveAction confirmSave:YES cancelAction:self.cancelAction confirmCancel:YES];
            }] forControlEvent:UIControlEventTouchUpInside];
            return cell;
        }
        case SectionPreload: {
            ToggleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];
            cell.titleLabel.text = l(@"Preload HSTS");
            cell.toggle.on = self.settings.preload;
            [cell.toggle addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
                self.settings.preload = sender.on;
                [self updateViewForSave:self.saveAction confirmSave:YES cancelAction:self.cancelAction confirmCancel:YES];
            }] forControlEvent:UIControlEventTouchUpInside];
            return cell;
        }
        case SectionNosniff: {
            ToggleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];
            cell.titleLabel.text = l(@"No-Sniff");
            cell.toggle.on = self.settings.nosniff;
            [cell.toggle addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
                self.settings.nosniff = sender.on;
                [self updateViewForSave:self.saveAction confirmSave:YES cancelAction:self.cancelAction confirmCancel:YES];
            }] forControlEvent:UIControlEventTouchUpInside];
            return cell;
        }
    }

    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"RightDetail"]) {
        [uihelper
         presentActionSheetInViewController:self
         attachToTarget:[ActionTipTarget targetWithView:cell]
         title:l(@"Select Maximum Age")
         subtitle:l(@"How long browser should cache the HSTS setting.")
         cancelButtonTitle:l(@"Cancel")
         items:ageTitles
         dismissed:^(NSInteger itemIndex) {
             if (itemIndex != -1) {
                 self.settings.max_age = [[self->ageValues objectAtIndex:itemIndex] unsignedIntegerValue];
                 [self.tableView reloadData];
                 [self updateViewForSave:self.saveAction confirmSave:YES cancelAction:self.cancelAction confirmCancel:YES];
             }
         }];
    }
}

@end
