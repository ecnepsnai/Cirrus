#import <UIKit/UIKit.h>

@interface ZoneMenuTableViewController : UITableViewController

- (void) showZoneMenuOnController:(UIViewController *)controller forZone:(CFZone *)zone finished:(void (^)(void))finished;

@end
