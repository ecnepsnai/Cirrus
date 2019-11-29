#import "DomainContactTableViewController.h"

@interface DomainContactTableViewController ()

@end

@implementation DomainContactTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.registrationProperties.contact.allKeys.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetail" forIndexPath:indexPath];
    
    NSString * key = self.registrationProperties.contact.allKeys[indexPath.row];
    NSString * value = self.registrationProperties.contact[key];
    
    cell.textLabel.text = [lang key:[NSString stringWithFormat:@"domainContactKey::%@", key]];
    if (value == nil || [value isEqual:[NSNull null]]) {
        cell.detailTextLabel.text = @"";
    } else {
        cell.detailTextLabel.text = value;
    }
    
    return cell;
}

@end
