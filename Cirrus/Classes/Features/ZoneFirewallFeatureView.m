#import "ZoneFirewallFeatureView.h"

@implementation ZoneFirewallFeatureView

static NSArray<NSString *> * ttlTitles;
static NSArray<NSString *> * ttlValues;

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        SegmentTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Segment" forIndexPath:indexPath];

        [cell.segment removeAllSegments];
        NSArray<NSString *> * titles = @[@"Off", @"Low", @"Medium", @"High"];
        for (NSInteger i = 0; i < titles.count; i ++) {
            [cell.segment insertSegmentWithTitle:titles[i] atIndex:i animated:NO];
        }

        CFZoneSettings * securitySetting = [self.options objectForKey:@"security_level"];
        if (nstrcmp(securitySetting.value, @"essentially_off")) {
            cell.segment.selectedSegmentIndex = 0;
        } else if (nstrcmp(securitySetting.value, @"low")) {
            cell.segment.selectedSegmentIndex = 1;
        } else if (nstrcmp(securitySetting.value, @"medium")) {
            cell.segment.selectedSegmentIndex = 2;
        } else if (nstrcmp(securitySetting.value, @"high")) {
            cell.segment.selectedSegmentIndex = 3;
            [cell.segment setTintColor:self.controller.view.tintColor];
        } else if (nstrcmp(securitySetting.value, @"under_attack")) {
            cell.segment.selectedSegmentIndex = 3;
            cell.segment.enabled = NO;
            [uihelper
             presentAlertInViewController:self.controller
             title:l(@"Settings Locked")
             body:l(@"You cannot alter firewall settings while you have 'I'm under attack' enabled.")
             dismissButtonTitle:l(@"Dismiss")
             dismissed:nil];
        }
        [self setModeToggleColor:cell.segment];

        [cell.segment addSelector:[[OCSelector alloc] initWithBlock:^(UISegmentedControl * sender) {
            [authManager authenticateUserForChange:NO success:^{
                CFZoneSettings * firewallSetting = [self.options objectForKey:@"security_level"];
                NSString * value = [@[@"essentially_off", @"low", @"medium", @"high", @"under_attack"] objectAtIndex:sender.selectedSegmentIndex];
                firewallSetting.value = value;
                [self.controller applySetting:firewallSetting];
                [self setModeToggleColor:sender];
            } cancelled:^{
                [tableView reloadData];
            }];
        }] forControlEvent:UIControlEventValueChanged];
        
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetail" forIndexPath:indexPath];

        if (!ttlTitles) {
            ttlTitles = @[l(@"5 minutes"), l(@"15 minutes"), l(@"30 minutes"), l(@"45 minutes"), l(@"1 hours"), l(@"2 hours"), l(@"3 hours"), l(@"4 hours"), l(@"8 hours"), l(@"16 hours"), l(@"1 day"), l(@"1 week"), l(@"1 month"), l(@"1 year")];
        }
        if (!ttlValues) {
            ttlValues = @[@"300", @"900", @"1800", @"2700", @"3600", @"7200", @"10800", @"14400", @"28800", @"57600", @"86400", @"604800", @"2592000", @"31536000"];
        }

        CFZoneSettings * challengeTTL = [self.options objectForKey:@"challenge_ttl"];
        NSUInteger index = [ttlValues indexOfObject:[challengeTTL.value stringValue]];
        if (index >= ttlValues.count) {
            cell.detailTextLabel.text = l(@"Custom");
        } else {
            cell.detailTextLabel.text = ttlTitles[index];
        }

        cell.textLabel.text = l(@"Challenge Passage");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }

    return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return l(@"Configuration");
    }
    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return l(@"Firewall_segment_description");
        case 1:
            return l(@"Specify how long a visitor is allowed access to your website after completing a challenge.");
    }
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [uihelper
         presentActionSheetInViewController:self.controller
         attachToTarget:[ActionTipTarget targetWithView:[tableView cellForRowAtIndexPath:indexPath]]
         title:l(@"Challenge Password")
         subtitle:l(@"Select new value")
         cancelButtonTitle:l(@"Cancel")
         items:ttlTitles
         dismissed:^(NSInteger itemIndex) {
             if (itemIndex != -1) {
                 [authManager authenticateUserForChange:NO success:^{
                     NSString * newValueString = ttlValues[itemIndex];
                     NSNumber * newValue = [NSNumber numberWithInteger:[newValueString integerValue]];
                     CFZoneSettings * challengeTTL = [self.options objectForKey:@"challenge_ttl"];
                     challengeTTL.value = newValue;
                     [self.controller applySetting:challengeTTL];
                     [self.controller.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                              withRowAnimation:UITableViewRowAnimationAutomatic];
                 } cancelled:nil];
             }
         }];
    }
}

- (NSString *) viewTitle {
    return l(@"Security Level");
}

- (void) setModeToggleColor:(UISegmentedControl *)segmentControl {
    if (segmentControl.selectedSegmentIndex == 0) {
        [segmentControl setTintColor:[UIColor materialRed]];
    } else if (segmentControl.selectedSegmentIndex == 1) {
        [segmentControl setTintColor:[UIColor materialAmber]];
    } else {
        [segmentControl setTintColor:self.controller.view.tintColor];
    }
}

@end
