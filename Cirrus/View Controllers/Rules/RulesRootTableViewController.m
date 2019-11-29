#import "RulesRootTableViewController.h"
#import "RuleListViewController.h"
#import "FontAwesome.h"

@interface RulesRootTableViewController () {
    BOOL showWAF;
}

@end

@implementation RulesRootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.tableView.estimatedRowHeight = 60.0f;
    self.title = l(@"Rules");

    showWAF = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (showWAF) {
        return 4;
    }
    return 3;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Rule" forIndexPath:indexPath];
    UILabel * titleLabel = [cell viewWithTag:1];
    UILabel * iconLabel = [cell viewWithTag:3];

    if (indexPath.row == 0) {
        titleLabel.text = @"Page";
        iconLabel.text = [NSString fontAwesomeIcon:FAFileSolid];
    } else if (indexPath.row == 1) {
        titleLabel.text = @"IP Firewall";
        iconLabel.text = [NSString fontAwesomeIcon:FAGlobeSolid];
    } else if (indexPath.row == 2) {
        titleLabel.text = @"Rate Limit";
        iconLabel.text = [NSString fontAwesomeIcon:FATachometerSolid];
    }  else if (indexPath.row == 3) {
        titleLabel.text = @"Web Application Firewall";
        iconLabel.text = [NSString fontAwesomeIcon:FACloudSolid];
    }
    
    iconLabel.textColor = uihelper.cirrusColor;

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * row;
    if (indexPath.row == 0) {
        row = @"page";
    } else if (indexPath.row == 1) {
        row = @"ip";
    } else if (indexPath.row == 2) {
        row = @"rate";
    }  else if (indexPath.row == 3) {
        row = @"waf";
    }
    [self performSegueWithIdentifier:@"ShowRules" sender:row];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(NSString *)sender {
    if (sender != nil && [segue.identifier isEqualToString:@"ShowRules"]) {
        RuleListViewController * rules = segue.destinationViewController;
        if ([sender isEqualToString:@"page"]) {
            [rules setRuleViewType:RuleViewTypePage];
        } else if ([sender isEqualToString:@"ip"]) {
            [rules setRuleViewType:RuleViewTypeFirewall];
        } else if ([sender isEqualToString:@"rate"]) {
            [rules setRuleViewType:RuleViewTypeRateLimit];
        } else if ([sender isEqualToString:@"waf"]) {
            [rules setRuleViewType:RuleViewTypeWAF];
        }
    }
}

@end
