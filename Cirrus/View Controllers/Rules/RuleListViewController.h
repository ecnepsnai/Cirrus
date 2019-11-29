#import <UIKit/UIKit.h>

@interface RuleListViewController : RefreshSearchTableViewController

typedef NS_ENUM(NSUInteger, RuleViewType) {
    RuleViewTypePage      = 0,
    RuleViewTypeFirewall  = 1,
    RuleViewTypeRateLimit = 2,
    RuleViewTypeWAF       = 3,
};

- (void) setRuleViewType:(RuleViewType)type;

@end
