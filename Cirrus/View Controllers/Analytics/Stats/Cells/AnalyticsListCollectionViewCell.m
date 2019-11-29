#import "AnalyticsListCollectionViewCell.h"

@interface AnalyticsListCollectionViewCell ()

@property (strong, nonatomic) NSArray<NSArray<NSString *> *> * listItems;

@end

@implementation AnalyticsListCollectionViewCell

- (void) setItems:(NSArray<NSArray<NSString *> *> *)items {
    self.listItems = items;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    [self.tableView reloadData];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SmallSubtitle" forIndexPath:indexPath];
    NSArray<NSString *> * item = self.listItems[indexPath.row];
    NSString * title = item[0];
    NSString * subtitle = item[1];

    UILabel * titleLabel = [cell viewWithTag:10];
    UILabel * subtitleLabel = [cell viewWithTag:20];
    
    titleLabel.text = title;
    subtitleLabel.text = subtitle;

    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listItems.count;
}

@end
