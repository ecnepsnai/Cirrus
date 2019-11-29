#import <UIKit/UIKit.h>

@interface UITableViewController (RefreshControl)

/**
 Add a refresh control to the current view.

 @param action Called when the user pulls down on the refresh control.
 */
- (void) addRefreshControlToTableWithAction:(OCSelector * _Nonnull)action DEPRECATED_MSG_ATTRIBUTE("Use RefreshSearchTableViewController instead");

/**
 Add a refrehs control with a title to the current view.

 @param title The title to display on the control.
 @param action Called when the user pulls down on the refresh control.
 */
- (void) addRefreshControlToTableWithTitle:(NSString * _Nullable)title action:(OCSelector * _Nonnull)action DEPRECATED_MSG_ATTRIBUTE("Use RefreshSearchTableViewController instead");

/**
 Show the refresh control and start animating.

 @param updateOffset Should update the offset of the table view controller.
                     Set this to YES when calling progmatically. Set to NO
                     when calling from the user pulling down event.
 */
- (void) showRefreshControlWithUpdatedOffset:(BOOL)updateOffset DEPRECATED_MSG_ATTRIBUTE("Use RefreshSearchTableViewController instead");

/**
 Hide the refresh control.
 */
- (void) hideRefreshControl DEPRECATED_MSG_ATTRIBUTE("Use RefreshSearchTableViewController instead");


@end
