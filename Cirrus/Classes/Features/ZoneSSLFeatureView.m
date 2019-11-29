#import "ZoneSSLFeatureView.h"

@interface ZoneSSLFeatureView ()

@end

@implementation ZoneSSLFeatureView

typedef NS_ENUM(NSUInteger, Section) {
    SectionCrypto = 0,
    SectionMinimumTLSVersion,
    SectionAuthOriginPulls,
    SectionOppEncryption,
    SectionAlwaysUseHTTPS,
    SectionHTTPSRewrites,

    SectionMAX,
};

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionCrypto) {
        SegmentTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Segment" forIndexPath:indexPath];

        [cell.segment removeAllSegments];
        NSArray<NSString *> * titles = @[@"Off", @"Flexible", @"Full", @"Strict"];
        for (NSInteger i = 0; i < titles.count; i ++) {
            [cell.segment insertSegmentWithTitle:titles[i] atIndex:i animated:NO];
        }

        CFZoneSettings * sslSetting = [self.options objectForKey:@"ssl"];
        if (nstrcmp(sslSetting.value, @"off")) {
            cell.segment.selectedSegmentIndex = 0;
        } else if (nstrcmp(sslSetting.value, @"flexible")) {
            cell.segment.selectedSegmentIndex = 1;
        } else if (nstrcmp(sslSetting.value, @"full")) {
            cell.segment.selectedSegmentIndex = 2;
        } else if (nstrcmp(sslSetting.value, @"strict")) {
            cell.segment.selectedSegmentIndex = 3;
        }
        [self setModeToggleColor:cell.segment];

        [cell.segment addSelector:[[OCSelector alloc] initWithBlock:^(UISegmentedControl * sender) {
            [authManager authenticateUserForChange:YES success:^{
                CFZoneSettings * sslSetting = [self.options objectForKey:@"ssl"];
                NSString * value = [@[@"off", @"flexible", @"full", @"strict"] objectAtIndex:sender.selectedSegmentIndex];
                [self confirmSarcasticResponseIf:[value isEqualToString:@"off"] completed:^{
                    sslSetting.value = value;
                    [self.controller applySetting:sslSetting];
                    [self setModeToggleColor:sender];
                } cancelled:^{
                    [tableView reloadData];
                }];
            } cancelled:^{
                [tableView reloadData];
            }];
        }] forControlEvent:UIControlEventValueChanged];

        return cell;
    } else if (indexPath.section == SectionMinimumTLSVersion) {
        SegmentTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Segment" forIndexPath:indexPath];
        [cell.segment removeAllSegments];
        NSArray<NSString *> * titles = @[@"1.0", @"1.1", @"1.2", @"1.3"];
        for (NSInteger i = 0; i < titles.count; i ++) {
            [cell.segment insertSegmentWithTitle:titles[i] atIndex:i animated:NO];
        }

        CFZoneSettings * sslSetting = [self.options objectForKey:@"min_tls_version"];
        if (nstrcmp(sslSetting.value, @"1.0")) {
            cell.segment.selectedSegmentIndex = 0;
        } else if (nstrcmp(sslSetting.value, @"1.1")) {
            cell.segment.selectedSegmentIndex = 1;
        } else if (nstrcmp(sslSetting.value, @"1.2")) {
            cell.segment.selectedSegmentIndex = 2;
        } else if (nstrcmp(sslSetting.value, @"1.3")) {
            cell.segment.selectedSegmentIndex = 3;
        }

        [cell.segment addSelector:[[OCSelector alloc] initWithBlock:^(UISegmentedControl * sender) {
            [authManager authenticateUserForChange:NO success:^{
                CFZoneSettings * sslSetting = [self.options objectForKey:@"min_tls_version"];
                NSString * value = [@[@"1.0", @"1.1", @"1.2", @"1.3"] objectAtIndex:sender.selectedSegmentIndex];
                sslSetting.value = value;
                [self.controller applySetting:sslSetting];
            } cancelled:^{
                [tableView reloadData];
            }];
        }] forControlEvent:UIControlEventValueChanged];

        return cell;
    } else if (indexPath.section == SectionAlwaysUseHTTPS) {
        ToggleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];

        cell.titleLabel.text = l(@"Always use HTTPS");
        CFZoneSettings * alwaysUseHTTPS = [self.options objectForKey:@"always_use_https"];
        cell.toggle.on = nstrcmp(alwaysUseHTTPS.value, @"on");
        [cell.toggle addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
            [authManager authenticateUserForChange:NO success:^{
                alwaysUseHTTPS.value = sender.on ? @"on" : @"off";
                [self.controller applySetting:alwaysUseHTTPS];
            } cancelled:^{
                [sender setOn:!sender.on animated:YES];
            }];
        }] forControlEvent:UIControlEventTouchUpInside];

        return cell;
    } else if (indexPath.section == SectionAuthOriginPulls) {
        ToggleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];

        cell.titleLabel.text = l(@"Authenticated Origin Pulls");
        CFZoneSettings * tlsClientAuth = [self.options objectForKey:@"tls_client_auth"];
        cell.toggle.on = nstrcmp(tlsClientAuth.value, @"on");
        [cell.toggle addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
            [authManager authenticateUserForChange:NO success:^{
                tlsClientAuth.value = sender.on ? @"on" : @"off";
                [self.controller applySetting:tlsClientAuth];
            } cancelled:^{
                [sender setOn:!sender.on animated:YES];
            }];
        }] forControlEvent:UIControlEventTouchUpInside];

        return cell;
    } else if (indexPath.section == SectionOppEncryption) {
        ToggleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];

        cell.titleLabel.text = l(@"Opportunistic Encryption");
        CFZoneSettings * opportunisticEncryption = [self.options objectForKey:@"opportunistic_encryption"];
        cell.toggle.on = nstrcmp(opportunisticEncryption.value, @"on");
        [cell.toggle addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
            [authManager authenticateUserForChange:NO success:^{
                opportunisticEncryption.value = sender.on ? @"on" : @"off";
                [self.controller applySetting:opportunisticEncryption];
            } cancelled:^{
                [sender setOn:!sender.on animated:YES];
            }];
        }] forControlEvent:UIControlEventTouchUpInside];

        return cell;
    } else if (indexPath.section == SectionHTTPSRewrites) {
        ToggleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Toggle" forIndexPath:indexPath];

        cell.titleLabel.text = l(@"Automatic HTTPS Rewrites");
        CFZoneSettings * httpsRewrite = [self.options objectForKey:@"automatic_https_rewrites"];
        cell.toggle.on = nstrcmp(httpsRewrite.value, @"on");
        [cell.toggle addSelector:[[OCSelector alloc] initWithBlock:^(UISwitch * sender) {
            [authManager authenticateUserForChange:NO success:^{
                httpsRewrite.value = sender.on ? @"on" : @"off";
                [self.controller applySetting:httpsRewrite];
            } cancelled:^{
                [sender setOn:!sender.on animated:YES];
            }];
        }] forControlEvent:UIControlEventTouchUpInside];

        return cell;
    }
    return nil;
}

- (void) confirmSarcasticResponseIf:(BOOL)condition completed:(void (^)())completed cancelled:(void (^)())cancelled {
    if (condition) {
        [uihelper presentConfirmInViewController:self.controller title:l(@"Uh why?") body:l(@"It's not 1996 anymore. HTTPS is free & faster than HTTP. You're doing your users a massive disservice by disabling HTTPS.") confirmButtonTitle:l(@"Disable HTTPS") cancelButtonTitle:l(@"Leave Enabled") confirmActionIsDestructive:YES dismissed:^(BOOL confirmed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (confirmed) {
                    completed();
                } else {
                    cancelled();
                }
            });
        }];
    } else {
        completed();
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionMAX;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SectionCrypto:
            return l(@"Configuration");
        case SectionMinimumTLSVersion:
            return l(@"Minimum TLS Version");
        case SectionAlwaysUseHTTPS:
        case SectionAuthOriginPulls:
        case SectionOppEncryption:
        case SectionHTTPSRewrites:
            return nil;
    }

    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case SectionCrypto:
            return l(@"SSL_segment_description");
        case SectionMinimumTLSVersion:
            return l(@"Only allow connections to this zone that use at least this version of TLS.");
        case SectionAlwaysUseHTTPS:
            return l(@"Redirect all HTTP requests to HTTPS.");
        case SectionAuthOriginPulls:
            return l(@"TLS client certificate presented for authentication on origin pull.");
        case SectionOppEncryption:
            return l(@"Tell browsers to use performance enhancing features like HTTP/2 and SPDY.");
        case SectionHTTPSRewrites:
            return l(@"Automatically rewrite HTTP requests to use HTTPS when the original page is served over HTTPS.");
    }

    return nil;
}

- (NSString *) viewTitle {
    return l(@"SSL/TLS");
}

- (void) setModeToggleColor:(UISegmentedControl *)segmentControl {
    if (segmentControl.selectedSegmentIndex == 0) {
        [segmentControl setTintColor:[UIColor materialRed]];
    } else if (segmentControl.selectedSegmentIndex == 1) {
        [segmentControl setTintColor:[UIColor materialAmber]];
    } else {
        [segmentControl setTintColor:uihelper.cirrusColor];
    }
}

@end
