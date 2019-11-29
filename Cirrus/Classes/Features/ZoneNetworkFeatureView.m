#import "ZoneNetworkFeatureView.h"

@implementation ZoneNetworkFeatureView

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ToggleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];

        cell.titleLabel.text = l(@"IPv6 Support");
        CFZoneSettings * ipv6 = [self.options objectForKey:@"ipv6"];

        BOOL isOn = nstrcmp(ipv6.value, @"on");

        cell.titleLabel.textColor = isOn ? [UIColor blackColor] : [UIColor materialRed];
        cell.toggle.on = isOn;
        [cell.toggle addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
            if (!sender.on) {
                [uihelper
                 presentConfirmInViewController:self.controller
                 title:l(@"Uh why?")
                 body:l(@"why_u_do_dis")
                 confirmButtonTitle:l(@"Disable IPv6")
                 cancelButtonTitle:l(@"Leave Enabled")
                 confirmActionIsDestructive:YES
                 dismissed:^(BOOL confirmed) {
                     if (confirmed) {
                         [authManager authenticateUserForChange:YES success:^{
                             ipv6.value = @"off";
                             [self.controller applySetting:ipv6];
                         } cancelled:^{
                             [sender setOn:YES animated:YES];
                         }];
                     } else {
                         [sender setOn:YES animated:YES];
                     }
                 }];
            } else {
                [authManager authenticateUserForChange:NO success:^{
                    ipv6.value = sender.on ? @"on" : @"off";
                    [self.controller applySetting:ipv6];
                } cancelled:^{
                    [sender setOn:NO animated:YES];
                }];
            }
        }] forControlEvent:UIControlEventTouchUpInside];

        return cell;
    } else if (indexPath.section == 1) {
        ToggleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];

        cell.titleLabel.text = l(@"Websockets");
        CFZoneSettings * websockets = [self.options objectForKey:@"websockets"];
        cell.toggle.on = nstrcmp(websockets.value, @"on");
        [cell.toggle addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
            [authManager authenticateUserForChange:NO success:^{
                websockets.value = sender.on ? @"on" : @"off";
                [self.controller applySetting:websockets];
            } cancelled:^{
                [sender setOn:!sender.on animated:YES];
            }];
        }] forControlEvent:UIControlEventTouchUpInside];

        return cell;
    } else if (indexPath.section == 2) {
        ToggleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];

        cell.titleLabel.text = l(@"IP Geolocation");
        CFZoneSettings * geolocation = [self.options objectForKey:@"ip_geolocation"];
        cell.toggle.on = nstrcmp(geolocation.value, @"on");
        [cell.toggle addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
            [authManager authenticateUserForChange:NO success:^{
                geolocation.value = sender.on ? @"on" : @"off";
                [self.controller applySetting:geolocation];
            } cancelled:^{
                [sender setOn:!sender.on animated:YES];
            }];
        }] forControlEvent:UIControlEventTouchUpInside];

        return cell;
    }
    return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return l(@"Enable IPv6 support for this zone.");
        case 1:
            return l(@"Allow websocket connections for this zone.");
        case 2:
            return l(@"Add an IPv4 header to requests when a client is using IPv6, but the server only supports IPv4.");
    }

    return nil;
}

- (NSString *) viewTitle {
    return l(@"Network");
}

@end
