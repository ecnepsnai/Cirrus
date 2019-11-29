#import <UIKit/UIKit.h>
#import "CFFirewallAccessRule.h"

@interface FirewallAccessRuleTableViewController : UITableViewController

- (void) setRule:(CFFirewallAccessRule *)rule finished:(void (^)(CFFirewallAccessRule * rule, BOOL saved))finished;

@end
