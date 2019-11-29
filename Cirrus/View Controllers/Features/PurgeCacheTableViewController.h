#import <UIKit/UIKit.h>

@interface PurgeCacheTableViewController : UITableViewController

/**
 The zone for this controller. As this controller can be presented outside of a zone context
 we cannot rely on the current zone in the app state, and have to manually set it when presenting
 the controller.
 */
@property (strong, nonatomic) CFZone * zone;
@property (nonatomic) BOOL showDoneButton;

@end
