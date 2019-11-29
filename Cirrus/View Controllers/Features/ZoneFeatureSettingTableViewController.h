#import <UIKit/UIKit.h>

@interface ZoneFeatureSettingTableViewController : UITableViewController

typedef NS_ENUM(NSUInteger, FeatureViewType) {
    FeatureViewTypeSSL = 0,
    FeatureViewTypeNetwork = 1,
    FeatureViewTypeSecurity = 2,
    FeatureViewTypeCaching = 3,
};

- (void) setFeatureViewType:(FeatureViewType)type;
- (void) applySetting:(CFZoneSettings *)setting;

@end
