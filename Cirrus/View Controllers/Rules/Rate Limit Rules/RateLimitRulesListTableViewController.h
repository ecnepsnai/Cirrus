#import <UIKit/UIKit.h>
#import "RuleListViewController.h"

@interface RateLimitRulesListTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) RuleListViewController * parent;

- (RateLimitRulesListTableViewController *) initWithParent:(RuleListViewController *)parent tableView:(UITableView *)tableView;
- (void) loadData;
- (void) createNew;
- (void) filterRules:(NSString *)query;
- (void) zoneChanged:(NSNotification *)n;

@end
