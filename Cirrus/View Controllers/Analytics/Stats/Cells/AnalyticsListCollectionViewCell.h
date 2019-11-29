#import <UIKit/UIKit.h>

@interface AnalyticsListCollectionViewCell : UICollectionViewCell <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void) setItems:(NSArray<NSArray<NSString *> *> *)items;

@end
