#import "FeaturesRootViewController.h"
#import "ZoneFeatureSettingTableViewController.h"

@interface FeaturesRootViewController ()

@end

@implementation FeaturesRootViewController

- (void)viewDidLoad {
    ZoneFeatureSettingTableViewController * controller = self.viewControllers[0];
    if ([self.restorationIdentifier isEqualToString:@"TLS"]) {
        [controller setFeatureViewType:FeatureViewTypeSSL];
    } else if ([self.restorationIdentifier isEqualToString:@"Network"]) {
        [controller setFeatureViewType:FeatureViewTypeNetwork];
    } else if ([self.restorationIdentifier isEqualToString:@"Security"]) {
        [controller setFeatureViewType:FeatureViewTypeSecurity];
    } else if ([self.restorationIdentifier isEqualToString:@"Caching"]) {
        [controller setFeatureViewType:FeatureViewTypeCaching];
    } else {
        NSAssert(NO, @"Unknown feature type '%@'", self.restorationIdentifier);
    }
    
    [super viewDidLoad];
}

@end
