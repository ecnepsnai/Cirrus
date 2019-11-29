#import <UIKit/UIKit.h>

@interface RateLimitRuleTableViewController : UITableViewController

- (void) setRule:(CFRateLimit *)rule finished:(void (^)(CFRateLimit * rule, BOOL saved))finished;

@end
