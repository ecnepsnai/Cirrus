#import <UIKit/UIKit.h>

@protocol RefreshSearchTableViewDelegate

- (void) userDidSearch:(NSString *)query;
- (void) userPulledToRefresh;

@end

@interface RefreshSearchTableViewController : UITableViewController

@property (strong, nonatomic) id<RefreshSearchTableViewDelegate> delegate;
@property (strong, nonatomic) UISearchController * searchController;
@property (nonatomic) BOOL isSearching;

@end
