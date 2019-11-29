#import <UIKit/UIKit.h>

@interface PageRuleForwardURLTableViewController : UITableViewController

- (void) setAction:(CFPageRuleAction *)action finished:(void (^)(BOOL cancelled, id newValue))finished;

@end
