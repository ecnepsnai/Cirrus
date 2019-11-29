#import "RefreshSearchTableViewController.h"

@interface RefreshSearchTableViewController () <UISearchResultsUpdating>

@end

@implementation RefreshSearchTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = self.searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = YES;
    } else {
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) pullToRefresh:(UIRefreshControl *)sender {
    [self.delegate userPulledToRefresh];
}

- (void) updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.delegate userDidSearch:searchController.searchBar.text];
}

- (BOOL) isSearching {
    return self.searchController.active && self.searchController.searchBar.text.length > 0;
}

@end
