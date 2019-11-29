#import "RefreshTableViewController.h"

@interface RefreshTableViewController ()

@end

@implementation RefreshTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) pullToRefresh:(UIRefreshControl *)sender {
    [self.delegate userPulledToRefresh];
}

@end
