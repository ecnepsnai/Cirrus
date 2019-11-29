#import <Foundation/Foundation.h>

@interface CFFirewallAccessRuleScope : NSObject

typedef NS_ENUM(short, FirewallAccessRuleScopeType) {
    FirewallAccessRuleScopeTypeZone,
    FirewallAccessRuleScopeTypeUser
};

@property (strong, nonatomic) NSString * identifier;
@property (strong, nonatomic) NSString * value;
@property (nonatomic) FirewallAccessRuleScopeType type;

+ (CFFirewallAccessRuleScope *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;
- (NSDictionary<NSString *, id> *) dictionaryValue;

@end
