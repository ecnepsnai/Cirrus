#import <Foundation/Foundation.h>
@import CMPopTipView;

@interface OCTipManager : NSObject

- (id _Nonnull) init;
+ (OCTipManager * _Nonnull) sharedInstance;

/**
 Show the presented tip only if the user has not seen it before.
 Use for tips that should only be seen once. If tip has already been seen this function does nothing.

 @param identifier The identifier of the tip
 @param config Called with an instantianted tip to be configured when presenting to user.
 */
- (void) showTipWithIdentifier:(NSString * _Nonnull)identifier configuration:(void (^ _Nonnull)(CMPopTipView * _Nonnull tip))config;

/**
 If visible, hide the tip with the given identifier

 @param identifier The identifier of the tip
 */
- (void) hideTipWithIdentifier:(NSString * _Nonnull)identifier;

/**
 Show a tip to the user
 Use for tips that should be shown at any time even if the user has seen it before.
 
 @param config Called with an instantianted tip to be configured.
 @return The CMPopTipView created
 */
- (CMPopTipView * _Nonnull) showTip:(void (^ _Nonnull)(CMPopTipView * _Nonnull tip))config;

@end
