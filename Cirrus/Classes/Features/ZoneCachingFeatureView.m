#import "ZoneCachingFeatureView.h"

@implementation ZoneCachingFeatureView

static NSArray<NSString *> * ttlTitles;
static NSArray<NSNumber *> * ttlValues;

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section){
        case 0: {
            SegmentTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Segment" forIndexPath:indexPath];
            
            [cell.segment removeAllSegments];
            NSArray<NSString *> * titles = @[@"No Query", @"Ignore Query", @"Standard"];
            for (NSInteger i = 0; i < titles.count; i ++) {
                [cell.segment insertSegmentWithTitle:titles[i] atIndex:i animated:NO];
            }
            
            CFZoneSettings * cachingLevelSetting = [self.options objectForKey:@"cache_level"];
            if (nstrcmp(cachingLevelSetting.value, @"basic")) {
                cell.segment.selectedSegmentIndex = 0;
            } else if (nstrcmp(cachingLevelSetting.value, @"simplified")) {
                cell.segment.selectedSegmentIndex = 1;
            } else if (nstrcmp(cachingLevelSetting.value, @"aggressive")) {
                cell.segment.selectedSegmentIndex = 2;
            }
            
            [cell.segment addSelector:[[OCSelector alloc] initWithBlock:^(UISegmentedControl * sender) {
                [authManager authenticateUserForChange:NO success:^{
                    CFZoneSettings * cachingSetting = [self.options objectForKey:@"cache_level"];
                    NSString * value = [@[@"basic", @"simplified", @"aggressive"] objectAtIndex:sender.selectedSegmentIndex];
                    cachingSetting.value = value;
                    [self.controller applySetting:cachingSetting];
                } cancelled:^{
                    [tableView reloadData];
                }];
            }] forControlEvent:UIControlEventValueChanged];
            
            return cell;
            break;
        } case 1: {
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetail" forIndexPath:indexPath];
            
            if (!ttlTitles) {
                ttlTitles = @[l(@"Respect Existing Headers"), l(@"2 hours"), l(@"3 hours"), l(@"4 hours"), l(@"5 hours"), l(@"8 hours"), l(@"12 hours"), l(@"16 hours"), l(@"20 hours"), l(@"1 day"), l(@"2 days"), l(@"3 days"), l(@"4 days"), l(@"5 days"), l(@"8 days"), l(@"16 days"), l(@"24 days"), l(@"1 month"), l(@"2 months"), l(@"6 months"), l(@"1 year")];
            }
            if (!ttlValues) {
                ttlValues = @[@0, @7200, @10800, @14400, @18000, @28800, @72000, @72000, @72000, @86400, @172800, @259200, @345600, @432000, @691200, @1382400, @2073600, @2678400, @5356800, @16070400, @32140800];
            }
            
            CFZoneSettings * browserTTL = [self.options objectForKey:@"browser_cache_ttl"];
            NSUInteger index = [ttlValues indexOfObject:browserTTL.value];
            if (index >= ttlValues.count) {
                cell.detailTextLabel.text = l(@"Custom");
            } else {
                cell.detailTextLabel.text = ttlTitles[index];
            }

            cell.textLabel.text = l(@"Browser Cache Expiration");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            break;
        } case 2: {
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
            cell.textLabel.text = l(@"Purge Cache");
            return cell;
            break;
        }
    }

    return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
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
            return l(@"Caching_segment_description");
        case 1:
            return l(@"Specify how long your visitors web browser should keep and serve a local copy of resources.");
    }
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [uihelper
         presentActionSheetInViewController:self.controller
         attachToTarget:[ActionTipTarget targetWithView:[tableView cellForRowAtIndexPath:indexPath]]
         title:l(@"Browser Cache Expiration")
         subtitle:l(@"Select new value")
         cancelButtonTitle:l(@"Cancel")
         items:ttlTitles
         dismissed:^(NSInteger itemIndex) {
             if (itemIndex != -1) {
                 [authManager authenticateUserForChange:NO success:^{
                     NSString * newValueString = [ttlValues[itemIndex] stringValue];
                     NSNumber * newValue = [NSNumber numberWithInteger:[newValueString integerValue]];
                     CFZoneSettings * browserTTL = [self.options objectForKey:@"browser_cache_ttl"];
                     browserTTL.value = newValue;
                     [self.controller applySetting:browserTTL];
                     [self.controller.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                              withRowAnimation:UITableViewRowAnimationAutomatic];
                 } cancelled:nil];
             }
         }];
    } else if (indexPath.section == 2) {
        [self.controller performSegueWithIdentifier:@"PurgeCache" sender:nil];
    }
}

- (NSString *) viewTitle {
    return l(@"Caching");
}

@end
