#import "CFPageRule.h"

@implementation CFPageRule

+ (CFPageRule *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFPageRule * rule = [CFPageRule new];
    rule.identifier = dictionary[@"id"];
    // Cloudflare appears to be future-proofing the possibility of allowing multiple targets for a single
    // page rule. We are not supporting that at this time.
    NSDictionary * target = [[dictionary objectForKey:@"targets"] objectAtIndex:0];
    NSDictionary * constraint = [target objectForKey:@"constraint"];
    rule.target = constraint[@"value"];
    rule.enabled = [[dictionary objectForKey:@"status"] isEqualToString:@"active"];
    rule.priority = [[dictionary objectForKey:@"priority"] integerValue];
    NSArray * actions = [dictionary objectForKey:@"actions"];
    NSMutableArray<CFPageRuleAction *> * ruleActions = [NSMutableArray new];
    for (NSDictionary * action in actions) {
        [ruleActions addObject:[CFPageRuleAction fromDictionary:action]];
    }
    rule.actions = ruleActions;
    return rule;
}

- (NSDictionary<NSString *, id> *) dictionaryValue {
    NSMutableDictionary * response = [NSMutableDictionary new];
    if (self.identifier) {
        [response setObject:self.identifier forKey:@"id"];
    }
    [response setObject:@[@{
        @"target": @"url",
        @"constraint": @{
            @"operator": @"matches",
            @"value": self.target
        }
    }] forKey:@"targets"];
    NSMutableArray * actions = [NSMutableArray new];
    for (CFPageRuleAction * action in self.actions) {
        [actions addObject:[action dictionaryValue]];
    }
    [response setObject:actions forKey:@"actions"];
    [response setObject:(self.enabled ? @"active" : @"disabled") forKey:@"status"];
    [response setObject:[NSNumber numberWithInteger:self.priority] forKey:@"priority"];
    return response;
}

+ (CFPageRule *) ruleWithDefaults {
    CFPageRule * rule = [CFPageRule new];
    rule.priority = 1;
    rule.enabled = YES;
    rule.target = format(@"https://%@", currentZone.name);
    return rule;
}

- (BOOL) objectMatchesQuery:(NSString *)query {
    if ([[self.target lowercaseString] containsString:query]) {
        return YES;
    }
    for (CFPageRuleAction * action in self.actions) {
        if ([action.value isKindOfClass:[NSString class]]) {
            if ([[action.value lowercaseString] containsString:query]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
