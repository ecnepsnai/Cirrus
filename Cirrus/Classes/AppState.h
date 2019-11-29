#import <UIKit/UIKit.h>
#import "CFZone.h"
#import "OCSelector.h"
#import "OCSplitViewController.h"
#import "ZoneListTableViewController.h"

/**
 The Application State is a class singleton class that is used as a broad state machine for the application
 and controlling aspects that affect the entire function of the app. It functions similarly to AppDelegate
 in the sense that it's accessible from any class, however AppState is not a delegate of anything.
 */
@interface AppState : NSObject

/**
 The current application state

 @return Returns a singleston instance of appState
 */
+ (AppState *) currentState;

/**
 Initalize a new application state instance, if one does not alerady exist

 @return Returns a singleton instance of appState
 */
- (id) init;

/**
 Perform first-run setup on the app, if needed. Calls finished(nil) when it's safe to load zones

 @param controller The view controller to perform first run on
 @param finished Called when finished with an error or nil on success
 */
- (void) firstRun:(UIViewController *)controller finished:(void (^)(NSError *))finished;

/**
 The current zone that the user is interacting with. Is changed whenever the user selects a new zone
 from the zone list
 */
@property (strong, nonatomic) CFZone * currentZone;

/**
 The email address of the user that's currently signed in
 */
@property (strong, nonatomic) NSString * userEmail;

/**
 Is the user currently signed in
 */
@property (nonatomic) BOOL isLoggedIn;

/**
 Refer to this when implementing the UITabBarPopToRoot shortcut to determine if you should perform the
 shortcut.
 */
@property (nonatomic) BOOL disableTabBarPopToRoot;

/**
 The split controller. On regular sized screens this functions as a normal split controller,
 with the zone list on the left and the zone on the right.

 On compact screens this controller presents the zoneNavigationController when the user enters
 a zone.
 */
@property (strong, nonatomic) OCSplitViewController * splitViewController;

/**
 The zone list view controller
 */
@property (strong, nonatomic) ZoneListTableViewController * zoneListViewController;

@end
