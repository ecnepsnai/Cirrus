#import "WAFRulesListTableViewController.h"

@interface WAFRulesListTableViewController ()

@end

@implementation WAFRulesListTableViewController

- (WAFRulesListTableViewController *) initWithParent:(RuleListViewController *)parent tableView:(UITableView *)tableView {
    self = [super init];
    self.parent = parent;
    self.tableView = tableView;
    return self;
}

- (void) loadData {

}

- (void) createNew {
    
}

- (void) filterRules:(NSString *)query {

}

- (void) zoneChanged:(NSNotification *)n {
    [self loadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
