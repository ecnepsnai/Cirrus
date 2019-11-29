#import "NavigationTableViewCell.h"
#import "OCIcon.h"

@interface NavigationTableViewCell ()

@property (nonatomic) FAIcon icon;
@property (strong, nonatomic, nonnull, readwrite) NSString * title;
@property (strong, nonatomic, nonnull, readwrite) NSString * storyboardName;
@property (strong, nonatomic, nonnull, readwrite) NSString * viewControllerIdentifier;

@end

@implementation NavigationTableViewCell

+ (instancetype) cellWithTitle:(NSString *)title icon:(FAIcon)icon storyboardName:(NSString *)storyboardName viewControllerIdentifier:(NSString *)viewControllerIdentifier {
    NavigationTableViewCell * cell = [NavigationTableViewCell new];
    cell.title = title;
    cell.icon = icon;
    cell.storyboardName = storyboardName;
    cell.viewControllerIdentifier = viewControllerIdentifier;
    return cell;
}

- (void) formatCell:(UITableViewCell *)cell {
    UILabel * iconLabel = [cell viewWithTag:2];
    UILabel * textLabel = [cell viewWithTag:1];
    iconLabel.font = [UIFont fontAwesomeFontForIcon:self.icon size:iconLabel.font.pointSize];
    iconLabel.text = [NSString fontAwesomeIcon:self.icon];
    textLabel.text = self.title;
}

- (UIViewController *) viewController {
    return viewControllerFromStoryboard(self.storyboardName, self.viewControllerIdentifier);
}

@end
