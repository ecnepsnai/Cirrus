#import <UIKit/UIKit.h>
#import "FontAwesome.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigationTableViewCell : NSObject

+ (instancetype) cellWithTitle:(NSString * _Nonnull)title icon:(FAIcon)icon storyboardName:(NSString * _Nonnull)storyboardName viewControllerIdentifier:(NSString * _Nonnull)viewControllerIdentifier;
- (void) formatCell:(UITableViewCell * _Nonnull)cell;
- (UIViewController * _Nonnull) viewController;

@end

NS_ASSUME_NONNULL_END
