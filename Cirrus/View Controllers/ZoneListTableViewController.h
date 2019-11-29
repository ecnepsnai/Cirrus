#import <UIKit/UIKit.h>
#import "DNSRecordsListTableViewController.h"
#import "ZoneSettingsTableViewController.h"
#import "RefreshSearchTableViewController.h"

@class DetailViewController;

@interface ZoneListTableViewController : RefreshSearchTableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

- (void) disableTableView;
- (void) enableTableView;

@end

