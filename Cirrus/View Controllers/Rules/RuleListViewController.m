#import "RuleListViewController.h"
#import "PageRulesListTableViewController.h"
#import "FirewallAccessRulesListTableViewController.h"
#import "RateLimitRulesListTableViewController.h"
#import "WAFRulesListTableViewController.h"

@interface RuleListViewController () <RefreshSearchTableViewDelegate> {
    RuleViewType viewType;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *viewToggle;
@property (strong, nonatomic) PageRulesListTableViewController * pageRulesList;
@property (strong, nonatomic) FirewallAccessRulesListTableViewController * firewallRuleList;
@property (strong, nonatomic) RateLimitRulesListTableViewController * rateLimitRulesList;
@property (strong, nonatomic) WAFRulesListTableViewController * wafRulesList;

@end

@implementation RuleListViewController

- (void) setRuleViewType:(RuleViewType)type {
    viewType = type;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self addZoneMenuButtonWithTitle:l(@"Rules")];
    
    self.navigationItem.rightBarButtonItems = @[
                                                self.editButtonItem,
                                                [[UIBarButtonItem alloc]
                                                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                 target:self
                                                 action:@selector(createNew)]];
    
    subscribe(@selector(zoneChanged:), NOTIF_ZONE_CHANGED);
    [self loadView:viewType];
}

- (void) userPulledToRefresh {
    [self loadData];
}

- (void) userDidSearch:(NSString *)query {
    NSString * search = [query lowercaseString];
    [self performSelectorOnRuleList:@selector(filterRules:) withValue:search];
}

- (void) updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString * search = [searchController.searchBar.text lowercaseString];
    [self userDidSearch:search];
}

- (void) zoneChanged:(NSNotification *)n {
    [self performSelectorOnRuleList:@selector(zoneChanged:) withValue:n];
}

- (void) loadData {
    [self performSelectorOnRuleList:@selector(loadData) withValue:nil];
}

- (void) createNew {
    [self performSelectorOnRuleList:@selector(createNew) withValue:nil];
}

- (void) performSelectorOnRuleList:(SEL)sel withValue:(id)object {
    IMP method;
    id caller;
    switch (viewType) {
        case RuleViewTypePage:
            caller = self.pageRulesList;
            break;
        case RuleViewTypeFirewall:
            caller = self.firewallRuleList;
            break;
        case RuleViewTypeRateLimit:
            caller = self.rateLimitRulesList;
            break;
        case RuleViewTypeWAF:
            caller = self.wafRulesList;
            break;
    }
    method = [caller methodForSelector:sel];
    void (*func)(__strong id, SEL, id) = (void (*)(__strong id, SEL, id))method;
    func(caller, sel, (__bridge id)(__bridge void *)object);
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction) viewChange:(UISegmentedControl *)sender {
    [self loadView:sender.selectedSegmentIndex];
}

- (void) loadView:(RuleViewType)type {
    self.firewallRuleList = nil;
    self.pageRulesList = nil;
    self.rateLimitRulesList = nil;
    self.wafRulesList = nil;

    switch (type) {
        case RuleViewTypePage:
            self.pageRulesList = [[PageRulesListTableViewController alloc] initWithParent:self tableView:self.tableView];
            self.tableView.delegate = self.pageRulesList;
            self.tableView.dataSource = self.pageRulesList;
            break;
        case RuleViewTypeFirewall:
            self.firewallRuleList = [[FirewallAccessRulesListTableViewController alloc] initWithParent:self tableView:self.tableView];
            self.tableView.delegate = self.firewallRuleList;
            self.tableView.dataSource = self.firewallRuleList;
            break;
        case RuleViewTypeRateLimit:
            self.rateLimitRulesList = [[RateLimitRulesListTableViewController alloc] initWithParent:self tableView:self.tableView];
            self.tableView.delegate = self.rateLimitRulesList;
            self.tableView.dataSource = self.rateLimitRulesList;
            break;
        case RuleViewTypeWAF:
            self.wafRulesList = [[WAFRulesListTableViewController alloc] initWithParent:self tableView:self.tableView];
            self.tableView.delegate = self.wafRulesList;
            self.tableView.dataSource = self.wafRulesList;
            break;
    }
}

@end
