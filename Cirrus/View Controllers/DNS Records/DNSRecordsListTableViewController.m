#import "DNSRecordsListTableViewController.h"
#import "CFDNSRecord.h"
#import "CFZone.h"
#import <QuartzCore/QuartzCore.h>
#import "EditDNSRecordTableViewController.h"
#import "DNSRecordTableViewCell.h"

@interface DNSRecordsListTableViewController () <RefreshSearchTableViewDelegate> {
    NSIndexPath * selectedIndexPath;
}

@property (strong, nonatomic) NSArray<CFDNSRecord *> * records;
@property (strong, nonatomic) NSMutableArray<CFDNSRecord *> * filteredRecords;
@property (strong, nonatomic) NSArray<UIColor *> * recordColors;

@end

@implementation DNSRecordsListTableViewController

- (void) viewDidLoad {
    self.delegate = self;

    NSMutableArray<UIColor *> * allMaterialColors = [NSMutableArray arrayWithArray:[UIColor allMaterialColors]];
    [allMaterialColors addObjectsFromArray:[UIColor allMaterialColors]];
    self.recordColors = allMaterialColors;

    [super viewDidLoad];

    self.title = l(@"DNS Records");
    if (zoneReadWrite) {
        self.navigationItem.rightBarButtonItems = @[
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNew:)],
            self.editButtonItem,
        ];
    }
    [self loadData];

    if (appState.splitViewController.displayMode != UISplitViewControllerDisplayModeAllVisible) {
        [[OCTipManager sharedInstance] showTipWithIdentifier:TIP_ZONE_DISMISS configuration:^(CMPopTipView *tip) {
            tip.message = l(@"Tap here to return to the zone list");
            [tip presentPointingAtView:self.navigationItem.titleView inView:self.view animated:YES];
        }];
    }

    self.tableView.rowHeight = 66.0f;
    self.definesPresentationContext = YES;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) userPulledToRefresh {

}

# pragma mark - Search View

- (void) userDidSearch:(NSString *)query {
    [self filterZones:query];
}

- (void) filterZones:(NSString *)query {
    self.filteredRecords = [NSMutableArray arrayWithCapacity:self.records.count];
    for (CFDNSRecord * record in self.records) {
        NSString * name = [record.name lowercaseString];
        NSString * content = [record.content lowercaseString];
        NSString * search = [query lowercaseString];
        if ([name containsString:search] || [content containsString:search]) {
            [self.filteredRecords addObject:record];
        }
    }

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) createNew:(UIBarButtonItem *)sender {
    [uihelper presentActionSheetInViewController:self
                                  attachToTarget:[ActionTipTarget targetWithBarButtonItem:self.navigationItem.rightBarButtonItem]
                                           title:l(@"Record Type")
                                        subtitle:nil
                               cancelButtonTitle:l(@"Cancel")
                                           items:SUPPORTED_RECORD_TYPES
                                       dismissed:^(NSInteger itemIndex) {
                                           if (itemIndex >= 0) {
                                               [self createNewForType:[SUPPORTED_RECORD_TYPES objectAtIndex:itemIndex]];
                                           }
                                       }];
}

- (void) createNewForType:(NSString *)type {
    CFDNSRecord * newRecord = [CFDNSRecord recordWithType:type];
    newRecord.zone_id = currentZone.identifier;
    newRecord.zone_name = currentZone.name;
    EditDNSRecordTableViewController * edit = [self.storyboard instantiateViewControllerWithIdentifier:@"EditDNSRecord"];
    [edit setDnsRecord:newRecord finished:^(BOOL cancelled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl beginRefreshing];
        });
        [self loadData];
    }];
    [self.navigationController pushViewController:edit animated:YES];
}

- (void) loadData {
    [api getAllDNSRecordsForZone:currentZone finished:^(NSArray<CFDNSRecord *> *records, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });

        if (error) {
            [uihelper presentErrorInViewController:self error:error dismissed:nil];
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.records = records;
            [self.tableView reloadData];

            if (self.records.count == 0) {
                [[OCTipManager sharedInstance] showTip:^(CMPopTipView * _Nonnull tip) {
                    tip.message = l(@"No DNS records. Tap here to create new record.");
                    [tip presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
                }];
            }
        });
    }];
}

#pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isSearching ? self.filteredRecords.count : self.records.count;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return zoneReadWrite;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DNSRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    CFDNSRecord * dns;
    if (self.isSearching) {
        dns = self.filteredRecords[indexPath.row];
    } else {
        dns = self.records[indexPath.row];
    }

    [cell configureForRecord:dns];
    cell.typeView.backgroundColor = [self.recordColors objectAtIndex:[SUPPORTED_RECORD_TYPES indexOfObject:dns.type]];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"SegueForEditDNS" sender:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueForEditDNS"]) {
        EditDNSRecordTableViewController * editDialog = [segue destinationViewController];

        CFDNSRecord * record;
        if (self.isSearching) {
            record = self.filteredRecords[selectedIndexPath.row];
        } else {
            record = self.records[selectedIndexPath.row];
        }

        // Use a copy to prevent discarded changes from appearing on the list
        CFDNSRecord * recordCopy = [CFDNSRecord fromDictionary:[record dictionaryValue]];
        [editDialog setDnsRecord:recordCopy finished:^(BOOL cancelled) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl beginRefreshing];
            });
            [self loadData];
        }];
    }
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [uihelper
         presentConfirmInViewController:self
         title:l(@"Are you sure you want to delete this record?")
         body:l(@"This action cannot be undone and may result in connectivity issues for your clients.")
         confirmButtonTitle:l(@"Delete")
         cancelButtonTitle:l(@"Cancel")
         confirmActionIsDestructive:YES
         dismissed:^(BOOL confirmed) {
             if (confirmed) {
                 [authManager authenticateUserForChange:YES success:^{
                     [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                     CFDNSRecord * record;
                     if (self.isSearching) {
                         record = self.filteredRecords[indexPath.row];
                     } else {
                         record = self.records[indexPath.row];
                     }
                     [api deleteDNSObject:record forZone:currentZone finished:^(BOOL success, NSError *error) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                         });

                         if (error) {
                             [uihelper presentErrorInViewController:self error:error dismissed:nil];
                         } else {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self.refreshControl beginRefreshing];
                             });
                             [self loadData];
                         }
                     }];
                 } cancelled:nil];
             }
         }];
    }
}

- (BOOL) tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL) tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void) tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        CFDNSRecord * record;
        if (self.isSearching) {
            record = self.filteredRecords[indexPath.row];
        } else {
            record = self.records[indexPath.row];
        }
        NSString * recordData = format(@"%@ %@", record.name, record.content);
        [[UIPasteboard generalPasteboard] setString:recordData];
    }
}

@end
