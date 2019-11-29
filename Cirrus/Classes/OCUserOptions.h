#import <Foundation/Foundation.h>

/**
 Describes the user configurable options.
 Property getter and setters directly reference user defaults.
 */
@interface OCUserOptions : NSObject

/**
 Returns the current set of user options
 @return A shared user options instance
 */
+ (OCUserOptions * _Nonnull) currentOptions;

/**
 Apply default values for missing keys. Won't overwrite any changes by the user.
 */
+ (void) setDefaultValues;

/**
 Should the app download, cache, and show site "favicon"
 */
@property (nonatomic) BOOL showFavicons;

/**
 Array of tip IDs that the user has seen
 */
@property (strong, nonatomic, nonnull) NSDictionary<NSString *, NSNumber *> * presentedTips;

/**
 Mapping of domain to timestamp of when favicon was saved
 */
@property (strong, nonatomic, nonnull) NSDictionary<NSString *, NSNumber *> * faviconAge;

/**
 Array of zone names that are "hidden" from the user
 */
@property (strong, nonatomic, nonnull) NSArray<NSString *> * hiddenZones;

/**
 Array of zone names that are "read only" to the user
 */
@property (strong, nonatomic, nonnull) NSArray<NSString *> * readOnlyZones;

/**
 Should the app require authentication when being used
 */
@property (nonatomic) BOOL deviceLock;

/**
 Should the app require authentication when making dangerous changes
 */
@property (nonatomic) BOOL deviceLockChanges;

/**
 Should the app require authentication when making any changes
 */
@property (nonatomic) BOOL deviceLockAllChanges;

/**
 Array of recently purged URLs
 */
@property (strong, nonatomic, nonnull) NSDictionary<NSString *, NSArray <NSString *> *> * recentlyPurgedURLs;

/**
 The index of the last used account
 */
@property (nonatomic) NSInteger lastUsedAccountIndex;

@end
