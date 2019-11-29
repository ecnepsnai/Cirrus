#import "CFFirewallAccessRuleScope.h"

@implementation CFFirewallAccessRuleScope

+ (CFFirewallAccessRuleScope *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFFirewallAccessRuleScope * scope = [CFFirewallAccessRuleScope new];

    scope.identifier = [dictionary objectForKey:@"id"];

    NSString * type = [dictionary objectForKey:@"type"];
    if ([type isEqualToString:@"user"]) {
        scope.type = FirewallAccessRuleScopeTypeUser;
    } else if ([type isEqualToString:@"zone"]) {
        scope.type = FirewallAccessRuleScopeTypeZone;
    }

    scope.value = [dictionary objectForKey:[scope valueKeyForType]];

    return scope;
}

- (NSDictionary<NSString *, id> *) dictionaryValue {
    NSMutableDictionary<NSString *, id> * dictionary = [NSMutableDictionary new];
    if (self.identifier) {
        [dictionary setValue:self.identifier forKey:@"id"];
    }

    NSString * type;
    switch (self.type) {
        case FirewallAccessRuleScopeTypeZone:
            type = @"zone";
            break;
        case FirewallAccessRuleScopeTypeUser:
            type = @"user";
            break;
    }
    [dictionary setObject:type forKey:@"type"];
    [dictionary setObject:self.value forKey:[self valueKeyForType]];

    return dictionary;
}

- (NSString *) valueKeyForType {
    switch (self.type) {
        case FirewallAccessRuleScopeTypeUser:
            return @"email";
        case FirewallAccessRuleScopeTypeZone:
            return @"name";
    }
}

@end
