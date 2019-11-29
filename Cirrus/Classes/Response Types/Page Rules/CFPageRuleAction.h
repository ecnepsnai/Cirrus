#import <Foundation/Foundation.h>

static NSDictionary<NSString *, NSDictionary *> * _Nonnull actionMapping;

@interface CFPageRuleAction : NSObject

typedef NS_ENUM(NSInteger, CFPageSetting) {
    CFPageSettingAlwaysOnline,
    CFPageSettingAlwaysUseHttps,
    CFPageSettingBrowserCacheTtl,
    CFPageSettingBrowserCheck,
    CFPageSettingCacheLevel,
    CFPageSettingDisableApps,
    CFPageSettingDisablePerformance,
    CFPageSettingDisableSecurity,
    CFPageSettingEdgeCacheTtl,
    CFPageSettingEmailObfuscation,
    CFPageSettingForwardingUrl,
    CFPageSettingIpGeolocation,
    CFPageSettingRocketLoader,
    CFPageSettingSecurityLevel,
    CFPageSettingServerSideExclude,
    CFPageSettingSmartErrors,
    CFPageSettingSsl,
    CFPageSettingAutomaticHttpsRewrites,
    CFPageSettingOpportunisticEncryption
};

@property (strong, nonatomic) NSString * _Nonnull identifier;
@property (nonatomic) CFPageSetting type;
@property (strong, nonatomic) id _Nullable value;
@property (nonatomic) BOOL exclusive;
@property (strong, nonatomic) NSDictionary<NSString *, id> * _Nonnull mapping;

+ (CFPageRuleAction * _Nonnull) fromDictionary:(NSDictionary<NSString *, id> * _Nonnull)dictionary;
- (NSDictionary<NSString *, id> * _Nonnull) dictionaryValue;

@end
