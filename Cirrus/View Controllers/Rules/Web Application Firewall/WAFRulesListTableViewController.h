#import <UIKit/UIKit.h>
#import "RuleListViewController.h"

@interface WAFRulesListTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) RuleListViewController * parent;

- (WAFRulesListTableViewController *) initWithParent:(RuleListViewController *)parent tableView:(UITableView *)tableView;
- (void) loadData;
- (void) createNew;
- (void) filterRules:(NSString *)query;
- (void) zoneChanged:(NSNotification *)n;

@end
