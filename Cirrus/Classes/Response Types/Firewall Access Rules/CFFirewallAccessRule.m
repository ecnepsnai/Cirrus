#import "CFFirewallAccessRule.h"

@implementation CFFirewallAccessRule

+ (CFFirewallAccessRule *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFFirewallAccessRule * rule = [CFFirewallAccessRule new];

    rule.identifier = [dictionary valueForKey:@"id"];
    NSString * mode = [dictionary valueForKey:@"mode"];
    if ([mode isEqualToString:@"block"]) {
        rule.mode = FirewallAccessRuleModeBlock;
    } else if ([mode isEqualToString:@"challenge"]) {
        rule.mode = FirewallAccessRuleModeChallenge;
    } else if ([mode isEqualToString:@"whitelist"]) {
        rule.mode = FirewallAccessRuleModeWhitelist;
    } else if ([mode isEqualToString:@"js_challenge"]) {
        rule.mode = FirewallAccessRuleModeJSChallenge;
    }
    rule.active = [[dictionary valueForKey:@"status"] isEqualToString:@"active"];
    id notes = [dictionary valueForKey:@"notes"];
    if (![notes isKindOfClass:[NSNull class]]) {
        rule.notes = notes;
    }
    rule.scope = [CFFirewallAccessRuleScope fromDictionary:[dictionary valueForKey:@"scope"]];
    rule.configuration = [CFFirewallAccessRuleConfiguration fromDictionary:[dictionary valueForKey:@"configuration"]];

    return rule;
}

- (NSString *) stringForMode {
    switch (self.mode) {
        case FirewallAccessRuleModeWhitelist:
            return @"whitelist";
        case FirewallAccessRuleModeBlock:
            return @"block";
        case FirewallAccessRuleModeChallenge:
            return @"challenge";
        case FirewallAccessRuleModeJSChallenge:
            return @"js_challenge";
    }
}

- (NSDictionary<NSString *, id> *) dictionaryValue {
    NSMutableDictionary<NSString *, id> * dict = [NSMutableDictionary
                                                  dictionaryWithDictionary:@{
                                                                             @"mode": [self stringForMode],
                                                                             @"status": self.active ? @"active" : @"disabled",
                                                                             @"notes": self.notes ?: [NSNull new],
                                                                             @"scope": [self.scope dictionaryValue],
                                                                             @"configuration": [self.configuration dictionaryValue]
                                                                             }];

    if (self.identifier) {
        [dict setValue:self.identifier forKey:@"id"];
    }

    return dict;
}

- (BOOL) objectMatchesQuery:(NSString *)query {
    if (self.notes && self.notes.length > 0 && [[self.notes lowercaseString] containsString:query]) {
        return YES;
    }
    if ([[self.configuration.value lowercaseString] containsString:query]) {
        return YES;
    }
    return NO;
}

@end
