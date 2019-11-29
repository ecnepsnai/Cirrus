#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ActionTipTarget.h"

@interface UIHelper : NSObject

/**
 *  Return a shared instance of the UIHelper class
 *
 *  @return A UIHelper class
 */
+ (UIHelper *) sharedInstance;

/**
 *  Set the apps appearance
 */
- (void) setAppearance;

/**
 *  The cirrus app color
 */
@property (strong, nonatomic) UIColor * cirrusColor;

/**
 *  Present an alert in the current view controller with only a dismiss button.
 *
 *  @param viewController     The view controller to present the alert on
 *  @param title              The alert title
 *  @param body               The alert body
 *  @param dismissButtonTitle The dismiss button title
 *  @param dismissed          Called when the alert was dismissed - the button index is not important
 */
- (void) presentAlertInViewController:(UIViewController *)viewController
    title:(NSString *)title
    body:(NSString *)body
    dismissButtonTitle:(NSString *)dismissButtonTitle
    dismissed:(void (^)(NSInteger buttonIndex))dismissed;

/**
 *  Present an alert in the current view controller with only a dismiss button.
 *
 *  @param viewController             The view controller to present the alert on
 *  @param title                      The alert title
 *  @param body                       The alert body
 *  @param confirmButtonTitle         The confirm button title
 *  @param cancelButtonTitle          The cancel button title
 *  @param textFieldConfiguration     Called when the textfield is to be configured
 *  @param dismissed                  Called when the alert was dismissed with the input value and if confirmed
 */
- (void) presentInputAlertInViewController:(UIViewController *)viewController
    title:(NSString *)title
    body:(NSString *)body
    confirmButtonTitle:(NSString *)confirmButtonTitle
    cancelButtonTitle:(NSString *)cancelButtonTitle
    textFieldConfiguration:(void (^)(UITextField * textField))textFieldConfiguration
    dismissed:(void (^)(NSString * inputValue, BOOL confirmed))dismissed;

/**
 *  Present an alert in the current view controller with up to three buttons.
 *
 *  @param viewController     The view controller to present the alert on
 *  @param title              The alert title
 *  @param body               The alert body
 *  @param buttons            The buttons to add to the alert. Maximum of 3.
 *  @param dismissed          Called when the alert was dismissed with the index of the button selected
 */
- (void) presentAlertInViewController:(UIViewController *)viewController
    title:(NSString *)title
    body:(NSString *)body
    buttons:(NSArray<NSString *> *)buttons
    dismissed:(void (^)(NSInteger buttonIndex))dismissed;

/**
 *  Convenience method to present an alert with an NSError object
 *
 *  @param viewController The view controller to present the alert on
 *  @param error          The error itself
 *  @param dismissed      Called when the alert was dismissed - the button index is not important
 */
- (void) presentErrorInViewController:(UIViewController *)viewController
    error:(NSError *)error
    dismissed:(void (^)(NSInteger buttonIndex))dismissed;

/**
 *  Presents a confirmation dialog in the current view controller with two buttons.
 *
 *  @param viewController             The view controller to present the alert on
 *  @param title                      The alert title
 *  @param body                       The alert body
 *  @param confirmButtonTitle         The confirm button title
 *  @param cancelButtonTitle          The cancel button title
 *  @param confirmActionIsDestructive On iOS 8+ setting this to YES will make the confirm button red
 *  @param dismissed                  Called when the alert was dismissed
 */
- (void) presentConfirmInViewController:(UIViewController *)viewController
    title:(NSString *)title
    body:(NSString *)body
    confirmButtonTitle:(NSString *)confirmButtonTitle
    cancelButtonTitle:(NSString *)cancelButtonTitle
    confirmActionIsDestructive:(BOOL)confirmActionIsDestructive
    dismissed:(void (^)(BOOL confirmed))dismissed;

/**
 *  Present an action sheet in the current view controller.
 *
 *  @param viewController    The view controller to present the alert on
 *  @param target            Attach the action sheet to this target UIView or bar button item (iPad only)
 *  @param title             The sheet title
 *  @param subtitle          The sheet subtitle (iOS 8+ only)
 *  @param cancelButtonTitle The cancel button title
 *  @param items             An array of strings for the buttons
 *  @param dismissed         Called when the sheet was dismissed
 */
- (void) presentActionSheetInViewController:(UIViewController *)viewController
    attachToTarget:(ActionTipTarget *)target
    title:(NSString *)title
    subtitle:(NSString *)subtitle
    cancelButtonTitle:(NSString *)cancelButtonTitle
    items:(NSArray<NSString *> *)items
    dismissed:(void (^)(NSInteger itemIndex))dismissed;

/**
 *  Present an action sheet in the current view controller.
 *
 *  @param viewController       The view controller to present the alert on
 *  @param target               Attach the action sheet to this target UIView or bar button item (iPad only)
 *  @param title                The sheet title
 *  @param subtitle             The sheet subtitle (iOS 8+ only)
 *  @param cancelButtonTitle    The cancel button title
 *  @param items                An array of strings for the buttons
 *  @param destructiveItemIndex The index of the destrictive item
 *  @param dismissed            Called when the sheet was dismissed
 */
- (void) presentActionSheetInViewController:(UIViewController *)viewController
    attachToTarget:(ActionTipTarget *)target
    title:(NSString *)title
    subtitle:(NSString *)subtitle
    cancelButtonTitle:(NSString *)cancelButtonTitle
    items:(NSArray<NSString *> *)items
    destructiveItemIndex:(NSInteger)destructiveItemIndex
    dismissed:(void (^)(NSInteger itemIndex))dismissed;

/**
 *  Apply better styles to the given button
 *
 *  @param button The button to update
 *  @param color  The color of the outline and the text
 */
- (void) applyStylesToButton:(UIButton *)button withColor:(UIColor *)color;

@end
