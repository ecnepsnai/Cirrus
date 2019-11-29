#import "HiddenZonesTableViewController.h"

@interface HiddenZonesTableViewController ()

@property (strong, nonatomic) NSMutableArray<NSString *> * hiddenZones;

@end

@implementation HiddenZonesTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    NSArray * zones = UserOptions.hiddenZones;
    if (zones == nil) {
        zones = @[];
    }
    self.hiddenZones = [NSMutableArray arrayWithArray:zones];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.hiddenZones.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
    cell.textLabel.text = [self.hiddenZones objectAtIndex:indexPath.row];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString * zone = [self.hiddenZones objectAtIndex:indexPath.row];
    [uihelper presentActionSheetInViewController:self attachToTarget:[ActionTipTarget targetWithView:cell] title:@"" subtitle:zone cancelButtonTitle:l(@"Cancel") items:@[l(@"Show Zone")] dismissed:^(NSInteger itemIndex) {
        if (itemIndex >= 0) {
            [self.hiddenZones removeObjectAtIndex:indexPath.row];
            notify(NOTIF_RELOAD_ZONES);
            [tableView reloadData];
            UserOptions.hiddenZones = self.hiddenZones;
        }
    }];
}

@end
