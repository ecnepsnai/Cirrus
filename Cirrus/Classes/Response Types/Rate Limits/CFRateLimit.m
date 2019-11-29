#import "CFRateLimit.h"

@implementation CFRateLimit

+ (CFRateLimit *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFRateLimit * limit = [CFRateLimit new];

    limit.identifier = [dictionary stringForKey:@"id"];
    limit.enabled = ![dictionary boolForKey:@"disabled"];
    limit.comment = [dictionary stringForKey:@"description"];
    limit.match = [CFRateLimitMatch fromDictionary:[dictionary dictionaryForKey:@"match"]];
    limit.action = [CFRateLimitAction fromDictionary:[dictionary dictionaryForKey:@"action"]];
    limit.threshold = [dictionary unsignedIntegerForKey:@"threshold"];
    limit.period = [dictionary unsignedIntegerForKey:@"period"];
    limit.loginProtect = [dictionary boolForKey:@"login_protect"];

    return limit;
}

- (NSDictionary<NSString *, id> *) dictionaryValue {
    return @{
             @"id": self.identifier,
             @"disabled": [NSNumber numberWithBool:!self.enabled],
             @"description": self.comment,
             @"match": [self.match dictionaryValue],
             @"action": [self.action dictionaryValue],
             @"threshold": [NSNumber numberWithUnsignedInteger:self.threshold],
             @"period": [NSNumber numberWithUnsignedInteger:self.period],
             @"login_protect": [NSNumber numberWithBool:self.loginProtect]
             };
}

+ (CFRateLimit *) ruleWithDefaults {
    CFRateLimit * rule = [CFRateLimit new];
    
    rule.enabled = YES;
    rule.match = [CFRateLimitMatch matchWithDefaults];
    rule.action = [CFRateLimitAction actionWithDefaults];
    rule.threshold = 10;
    rule.period = 1;
    
    return rule;
}

- (NSString *) description {
    return format(@"Rate limit rule \"%@\": %@", self.comment, [self ruleDescription]);
}

- (NSString *) ruleDescription {
    return [lang
            key:@"{requestCount} requests per {threshold}, block for {time}"
            args:@[
                   format(@"%lu", (unsigned long)self.threshold),
                   [OCStringFormatter.sharedInstance formatSecondsToFriendlyTime:self.period],
                   [OCStringFormatter.sharedInstance formatSecondsToFriendlyTime:self.action.timeout]
                   ]
            ];
}

- (BOOL) objectMatchesQuery:(NSString *)query {
    if ([self.comment.lowercaseString containsString:query]) {
        return YES;
    }

    if ([self.match.request.url.lowercaseString containsString:query]) {
        return YES;
    }

    return NO;
}

@end
