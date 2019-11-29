#import <UIKit/UIKit.h>

@interface ZoneTableViewCell : UITableViewCell

- (void) configureCellForZone:(CFZone * _Nonnull)zone onController:(UIViewController * _Nonnull)controller;

@end
