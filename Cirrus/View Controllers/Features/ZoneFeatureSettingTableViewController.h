#import <UIKit/UIKit.h>

@interface ZoneFeatureSettingTableViewController : UITableViewController

/**
 Load the feature options into the view controller

 @param options The options
 @param type    The type of view to display
 @param zone    The zone
 */
- (void) loadWithOptions:(NSDictionary<NSString *, CFZoneSettings *> *)options
                  ofType:(NSString *)type;

/**
 Apply the current setting to the zone

 @param setting The setting object to save
 */
- (void) applySetting:(CFZoneSettings *)setting;

@end
