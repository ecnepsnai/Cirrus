#import "CFPageRuleAction.h"

@implementation CFPageRuleAction

- (id) init {
    self = [super init];
    if (!actionMapping) {
        actionMapping = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Page Rules" ofType:@"plist"]];
    }
    return self;
}

+ (CFPageRuleAction *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFPageRuleAction * action = [CFPageRuleAction new];
    action.identifier = dictionary[@"id"];

    id value = [dictionary objectForKey:@"value"];
    if (value) {
        action.value = value;
    }
    return action;
}

- (void) setIdentifier:(NSString *)identifier {
    _identifier = identifier;

    if ([identifier isEqualToString:@"always_online"]) {
        self.type = CFPageSettingAlwaysOnline;
    } else if ([identifier isEqualToString:@"always_use_https"]) {
        self.type = CFPageSettingAlwaysUseHttps;
    } else if ([identifier isEqualToString:@"browser_cache_ttl"]) {
        self.type = CFPageSettingBrowserCacheTtl;
    } else if ([identifier isEqualToString:@"browser_check"]) {
        self.type = CFPageSettingBrowserCheck;
    } else if ([identifier isEqualToString:@"cache_level"]) {
        self.type = CFPageSettingCacheLevel;
    } else if ([identifier isEqualToString:@"disable_apps"]) {
        self.type = CFPageSettingDisableApps;
    } else if ([identifier isEqualToString:@"disable_performance"]) {
        self.type = CFPageSettingDisablePerformance;
    } else if ([identifier isEqualToString:@"disable_security"]) {
        self.type = CFPageSettingDisableSecurity;
    } else if ([identifier isEqualToString:@"edge_cache_ttl"]) {
        self.type = CFPageSettingEdgeCacheTtl;
    } else if ([identifier isEqualToString:@"email_obfuscation"]) {
        self.type = CFPageSettingEmailObfuscation;
    } else if ([identifier isEqualToString:@"forwarding_url"]) {
        self.type = CFPageSettingForwardingUrl;
    } else if ([identifier isEqualToString:@"ip_geolocation"]) {
        self.type = CFPageSettingIpGeolocation;
    } else if ([identifier isEqualToString:@"rocket_loader"]) {
        self.type = CFPageSettingRocketLoader;
    } else if ([identifier isEqualToString:@"security_level"]) {
        self.type = CFPageSettingSecurityLevel;
    } else if ([identifier isEqualToString:@"server_side_exclude"]) {
        self.type = CFPageSettingServerSideExclude;
    } else if ([identifier isEqualToString:@"smart_errors"]) {
        self.type = CFPageSettingSmartErrors;
    } else if ([identifier isEqualToString:@"ssl"]) {
        self.type = CFPageSettingSsl;
    } else if ([identifier isEqualToString:@"automatic_https_rewrites"]) {
        self.type = CFPageSettingAutomaticHttpsRewrites;
    } else if ([identifier isEqualToString:@"opportunistic_encryption"]) {
        self.type = CFPageSettingOpportunisticEncryption;
    }
    
    self.mapping = [actionMapping objectForKey:identifier];
    if (self.mapping) {
        self.exclusive = [[self.mapping objectForKey:@"exclusive"] boolValue] || NO;
    }
}

- (NSDictionary<NSString *, id> *) dictionaryValue {
    NSMutableDictionary * response = [NSMutableDictionary new];
    [response setObject:self.identifier forKey:@"id"];
    if (self.value) {
        [response setObject:self.value forKey:@"value"];
    }
    return response;
}

@end
