#import <Foundation/Foundation.h>
#import "CFFirewallAccessRuleScope.h"
#import "CFFirewallAccessRuleConfiguration.h"

@interface CFFirewallAccessRule : NSObject <OCSearchDelegate>

typedef NS_ENUM(short, FirewallAccessRuleMode) {
    FirewallAccessRuleModeWhitelist,
    FirewallAccessRuleModeBlock,
    FirewallAccessRuleModeChallenge,
    FirewallAccessRuleModeJSChallenge
};

@property (strong, nonatomic) NSString * identifier;
@property (nonatomic) FirewallAccessRuleMode mode;
@property (nonatomic) BOOL active;
@property (strong, nonatomic) NSString * notes;
@property (strong, nonatomic) CFFirewallAccessRuleScope * scope;
@property (strong, nonatomic) CFFirewallAccessRuleConfiguration * configuration;

+ (CFFirewallAccessRule *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;
- (NSDictionary<NSString *, id> *) dictionaryValue;
- (NSString *) stringForMode;

@end
