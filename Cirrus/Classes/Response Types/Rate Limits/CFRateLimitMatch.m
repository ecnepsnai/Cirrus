#import "CFRateLimitMatch.h"

@implementation CFRateLimitMatchRequest

+ (CFRateLimitMatchRequest *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFRateLimitMatchRequest * request = [CFRateLimitMatchRequest new];

    request.methods = [dictionary arrayForKey:@"methods"];
    request.schemes = [dictionary arrayForKey:@"schemes"];
    request.url = [dictionary stringForKey:@"url"];

    return request;
}

+ (CFRateLimitMatchRequest *) requesthWithDefaults {
    CFRateLimitMatchRequest * request = [CFRateLimitMatchRequest new];
    
    request.schemes = @[@"_ALL_"];
    request.url = currentZone.name;
    
    return request;
}

- (NSDictionary<NSString *, id> *) dictionaryValue {
    return @{
             @"methods": self.methods ?: [NSNull new],
             @"schemes": self.schemes ?: [NSNull new],
             @"url": self.url
             };
}

@end

@implementation CFRateLimitMatchResponse

+ (CFRateLimitMatchResponse *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFRateLimitMatchResponse * response = [CFRateLimitMatchResponse new];

    response.origin_traffic = [dictionary boolForKey:@"origin_traffic"];
    response.status = [dictionary arrayForKey:@"status"];

    return response;
}

+ (CFRateLimitMatchResponse *) responseWithDefaults {
    return [CFRateLimitMatchResponse new];
}

- (NSDictionary<NSString *, id> *) dictionaryValue {
    return @{
             @"origin_traffic": [NSNumber numberWithBool:self.origin_traffic],
             @"status": self.status ?: [NSNull new]
             };
}

@end

@implementation CFRateLimitMatch

+ (CFRateLimitMatch *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFRateLimitMatch * match = [CFRateLimitMatch new];

    match.request = [CFRateLimitMatchRequest fromDictionary:[dictionary dictionaryForKey:@"request"]];
    match.response = [CFRateLimitMatchResponse fromDictionary:[dictionary dictionaryForKey:@"response"]];

    return match;
}

+ (CFRateLimitMatch *) matchWithDefaults {
    CFRateLimitMatch * match = [CFRateLimitMatch new];
    
    match.request = [CFRateLimitMatchRequest requesthWithDefaults];
    match.response = [CFRateLimitMatchResponse responseWithDefaults];
    
    return match;
}

- (NSDictionary<NSString *, id> *) dictionaryValue {
    return @{
             @"request": [self.request dictionaryValue],
             @"response": [self.response dictionaryValue]
             };
}

@end
