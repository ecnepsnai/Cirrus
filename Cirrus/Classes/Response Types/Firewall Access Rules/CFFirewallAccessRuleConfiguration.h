#import <Foundation/Foundation.h>

@interface CFFirewallAccessRuleConfiguration : NSObject

typedef NS_ENUM(short, FirewallAccessRuleConfigurationTarget) {
    FirewallAccessRuleConfigurationTargetIP,
    FirewallAccessRuleConfigurationTargetCountry,
    FirewallAccessRuleConfigurationTargetIPRange,
    FirewallAccessRuleConfigurationTargetASN
};

@property (nonatomic) FirewallAccessRuleConfigurationTarget target;
@property (strong, nonatomic) NSString * value;

+ (CFFirewallAccessRuleConfiguration *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;
- (NSDictionary<NSString *, id> *) dictionaryValue;

@end
