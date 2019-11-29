#import <UIKit/UIKit.h>

@protocol RefreshTableViewDelegate

- (void) userPulledToRefresh;

@end

@interface RefreshTableViewController : UITableViewController

@property (strong, nonatomic) id<RefreshTableViewDelegate> delegate;

@end
