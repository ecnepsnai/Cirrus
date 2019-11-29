#import "CFFirewallAccessRuleConfiguration.h"

@implementation CFFirewallAccessRuleConfiguration

+ (CFFirewallAccessRuleConfiguration *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFFirewallAccessRuleConfiguration * config = [CFFirewallAccessRuleConfiguration new];

    config.value = [dictionary objectForKey:@"value"];

    NSString * target = [dictionary valueForKey:@"target"];
    if ([target isEqualToString:@"ip"]) {
        config.target = FirewallAccessRuleConfigurationTargetIP;
    } else if ([target isEqualToString:@"asn"]) {
        config.target = FirewallAccessRuleConfigurationTargetASN;
    } else if ([target isEqualToString:@"country"]) {
        config.target = FirewallAccessRuleConfigurationTargetCountry;
    } else if ([target isEqualToString:@"ip_range"]) {
        config.target = FirewallAccessRuleConfigurationTargetIPRange;
    }

    return config;
}

- (NSString *) targetAsString {
    switch (self.target) {
        case FirewallAccessRuleConfigurationTargetIP:
            return @"ip";
        case FirewallAccessRuleConfigurationTargetASN:
            return @"asn";
        case FirewallAccessRuleConfigurationTargetCountry:
            return @"country";
        case FirewallAccessRuleConfigurationTargetIPRange:
            return @"ip_range";
    }
}

- (NSDictionary<NSString *, id> *) dictionaryValue {
    return @{
             @"value": self.value,
             @"target": [self targetAsString]
             };
}

@end
