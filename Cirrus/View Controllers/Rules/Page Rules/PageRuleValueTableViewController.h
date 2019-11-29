#import <UIKit/UIKit.h>

@interface PageRuleValueTableViewController : UITableViewController

- (void) setAction:(CFPageRuleAction *)action finished:(void (^)(BOOL cancelled, id newValue))finished;

@end
