#import "RulesRootViewController.h"
#import "RuleListViewController.h"

@interface RulesRootViewController ()

@end

@implementation RulesRootViewController

- (void) viewDidLoad {
    RuleListViewController * rules = self.viewControllers[0];

    if ([self.restorationIdentifier isEqualToString:@"Page"]) {
        [rules setRuleViewType:RuleViewTypePage];
    } else if ([self.restorationIdentifier isEqualToString:@"IPFirewall"]) {
        [rules setRuleViewType:RuleViewTypeFirewall];
    } else if ([self.restorationIdentifier isEqualToString:@"RateLimit"]) {
        [rules setRuleViewType:RuleViewTypeRateLimit];
    } else if ([self.restorationIdentifier isEqualToString:@"WAF"]) {
        [rules setRuleViewType:RuleViewTypeWAF];
    } else {
        NSAssert(NO, @"Unrecognized rule type", self.restorationIdentifier);
    }

    [super viewDidLoad];
}

@end
