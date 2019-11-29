#import <Foundation/Foundation.h>
#import "ZoneFeatureSettingTableViewController.h"

@interface OCZoneFeatureView : NSObject

@property (strong, nonatomic) ZoneFeatureSettingTableViewController * controller;
@property (strong, nonatomic) NSDictionary<NSString *, CFZoneSettings *> * options;

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView;
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *) viewTitle;

@end
