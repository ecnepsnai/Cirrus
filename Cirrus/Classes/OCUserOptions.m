#import "OCUserOptions.h"

@interface OCUserOptions ()

@end

@implementation OCUserOptions

static OCUserOptions * _instance;

#define STORAGE_KEY_SHOW_FAVICONS             @"show_favicons"
#define STORAGE_KEY_PRESENTED_TIPS            @"presented_tips"
#define STORAGE_KEY_FAVICON_AGE               @"favicon_age"
#define STORAGE_KEY_HIDDEN_ZONES              @"hidden_zones"
#define STORAGE_KEY_READ_ONLY_ZONES              @"read_only_zones"
#define STORAGE_KEY_DEVICE_LOCK               @"device_lock"
#define STORAGE_KEY_DEVICE_LOCK_CHANGES       @"device_lock_changes"
#define STORAGE_KEY_DEVICE_LOCK_CHANGE_ALL    @"device_lock_all_changes"
#define STORAGE_KEY_RECENTLY_PURGED_URLS      @"recently_purged_urls"
#define STORAGE_KEY_LAST_USED_ACCOUNT_INDEX   @"last_used_account"
#define AppDefaults [NSUserDefaults standardUserDefaults]

+ (OCUserOptions * _Nonnull) currentOptions {
    if (!_instance) {
        _instance = [OCUserOptions new];
    }
    return _instance;
}

- (id _Nonnull) init {
    if (!_instance) {
        _instance = [super init];
    }
    return _instance;
}

+ (void) setDefaultValues {
    NSDictionary<NSString *, id> * defaults = @{
                                                STORAGE_KEY_SHOW_FAVICONS: @YES,
                                                STORAGE_KEY_HIDDEN_ZONES: @[],
                                                STORAGE_KEY_READ_ONLY_ZONES: @[],
                                                STORAGE_KEY_PRESENTED_TIPS: @{},
                                                STORAGE_KEY_RECENTLY_PURGED_URLS: @{}
                                                };

    for (NSString * key in defaults.allKeys) {
        if ([AppDefaults valueForKey:key] == nil) {
            [AppDefaults setValue:defaults[key] forKey:key];
        }
    }
}

- (BOOL) showFavicons {
    return [AppDefaults boolForKey:STORAGE_KEY_SHOW_FAVICONS];
}

- (void) setShowFavicons:(BOOL)showFavicons {
    [AppDefaults setBool:showFavicons forKey:STORAGE_KEY_SHOW_FAVICONS];
}

- (NSDictionary<NSString *, NSNumber *> *) presentedTips {
    return [AppDefaults dictionaryForKey:STORAGE_KEY_PRESENTED_TIPS];
}

- (void) setPresentedTips:(NSDictionary<NSString *, NSNumber *> *)presentedTips {
    [AppDefaults setValue:presentedTips forKey:STORAGE_KEY_PRESENTED_TIPS];
}

- (NSDictionary<NSString *, NSNumber *> *) faviconAge {
    return [AppDefaults dictionaryForKey:STORAGE_KEY_FAVICON_AGE];
}

- (void) setFaviconAge:(NSDictionary<NSString *, NSNumber *> *)faviconAge {
    [AppDefaults setValue:faviconAge forKey:STORAGE_KEY_FAVICON_AGE];
}

- (NSArray<NSString *> *) hiddenZones {
    return [AppDefaults arrayForKey:STORAGE_KEY_HIDDEN_ZONES];
}

- (void) setHiddenZones:(NSArray<NSString *> *)hiddenZones {
    [AppDefaults setValue:hiddenZones forKey:STORAGE_KEY_HIDDEN_ZONES];
}

- (NSArray<NSString *> *) readOnlyZones {
    return [AppDefaults arrayForKey:STORAGE_KEY_READ_ONLY_ZONES];
}

- (void) setReadOnlyZones:(NSArray<NSString *> *)readOnlyZones {
    [AppDefaults setValue:readOnlyZones forKey:STORAGE_KEY_READ_ONLY_ZONES];
}

- (BOOL) deviceLock {
    return [AppDefaults boolForKey:STORAGE_KEY_DEVICE_LOCK];
}

- (void) setDeviceLock:(BOOL)deviceLock {
    [AppDefaults setBool:deviceLock forKey:STORAGE_KEY_DEVICE_LOCK];
}

- (BOOL) deviceLockChanges {
    return [AppDefaults boolForKey:STORAGE_KEY_DEVICE_LOCK_CHANGES];
}

- (void) setDeviceLockChanges:(BOOL)deviceLockChanges {
    [AppDefaults setBool:deviceLockChanges forKey:STORAGE_KEY_DEVICE_LOCK_CHANGES];
}

- (BOOL) deviceLockAllChanges {
    return [AppDefaults boolForKey:STORAGE_KEY_DEVICE_LOCK_CHANGE_ALL];
}

- (void) setDeviceLockAllChanges:(BOOL)deviceLockAllChanges {
    [AppDefaults setBool:deviceLockAllChanges forKey:STORAGE_KEY_DEVICE_LOCK_CHANGE_ALL];
}

- (NSDictionary<NSString *, NSArray <NSString *> *> *) recentlyPurgedURLs {
    return [AppDefaults dictionaryForKey:STORAGE_KEY_RECENTLY_PURGED_URLS];
}

- (void) setRecentlyPurgedURLs:(NSDictionary<NSString *, NSArray <NSString *> *> *)recentlyPurgedURLs {
    [AppDefaults setValue:recentlyPurgedURLs forKey:STORAGE_KEY_RECENTLY_PURGED_URLS];
}

- (NSInteger) lastUsedAccountIndex {
    return [AppDefaults integerForKey:STORAGE_KEY_LAST_USED_ACCOUNT_INDEX];
}

- (void) setLastUsedAccountIndex:(NSInteger)lastUsedAccountIndex {
    [AppDefaults setInteger:lastUsedAccountIndex forKey:STORAGE_KEY_LAST_USED_ACCOUNT_INDEX];
}

@end
