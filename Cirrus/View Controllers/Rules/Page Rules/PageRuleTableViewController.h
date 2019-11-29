#import <UIKit/UIKit.h>

@interface PageRuleTableViewController : UITableViewController

- (void) setRule:(CFPageRule *)rule finished:(void (^)(CFPageRule * rule, BOOL saved))finished;

@end
