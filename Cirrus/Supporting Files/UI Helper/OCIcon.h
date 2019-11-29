#import <Foundation/Foundation.h>

@interface OCIcon : NSObject

/**
 Icon alias codes
 */
typedef NS_ENUM(NSUInteger, OCIconCode) {
    OCIconCodeActive,
    OCIconCodePaused,
    OCIconCodeDevMode,
    OCIconCodeMoved,
    OCIconCodeReadOnly,
};

/**
 Instantiate a new icon class

 @param code The icon code
 @return An icon class
 */
+ (OCIcon * _Nonnull) iconForCode:(OCIconCode)code;

/**
 Configure the given label for the icon

 @param label The label to configure. Should be ONLY used for icons.
 */
- (void) configureLabel:(UILabel * _Nonnull)label;

@end
