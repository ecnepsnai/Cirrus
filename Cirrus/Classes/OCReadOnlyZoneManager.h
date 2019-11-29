#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Manager for interacting with read-only zones
@interface OCReadOnlyZoneManager : NSObject

/// Return the shared instance of the read-only zone manager
+ (OCReadOnlyZoneManager * _Nonnull) sharedInstance;

/// Mark this zone as read only
/// @param zone The zone to make read only
- (void) markZoneAsReadOnly:(CFZone * _Nonnull) zone;

/// Mark this zone as read write
/// @param zone The zone to make read write
- (void) markZoneAdReadWrite:(CFZone * _Nonnull) zone;

/// Is this zone read only
/// @param zone The zone to check
- (BOOL) zoneIsReadOnly:(CFZone * _Nonnull) zone;

@end

NS_ASSUME_NONNULL_END
