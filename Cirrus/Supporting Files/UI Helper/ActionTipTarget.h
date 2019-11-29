#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ActionTipTarget : NSObject

@property (strong, nonatomic) UIView * targetView;
@property (strong, nonatomic) UIBarButtonItem * targetBarButtonItem;

/*
 *  Create a new action tip targeting the given UIView
 *
 *  @param view The view to target
 *
 *  @returns An action tip target
 */
+ (ActionTipTarget *) targetWithView:(UIView *)view;

/*
 *  Create a new action tip targeting the given UIBarButtonItem
 *
 *  @param barButtonItem The bar button item to target
 *
 *  @returns An action tip target
 */
+ (ActionTipTarget *) targetWithBarButtonItem:(UIBarButtonItem *)barButtonItem;

@end
