#import "CFHSTSSettings.h"

@implementation CFHSTSSettings

+ (CFHSTSSettings *) fromDictionary:(NSDictionary<NSString *, NSNumber *> *)dictionary {
    CFHSTSSettings * settings = [CFHSTSSettings new];
    settings.enabled = [dictionary boolForKey:@"enabled"];
    settings.max_age = [[dictionary numberForKey:@"max_age"] unsignedIntegerValue];
    settings.include_subdomains = [dictionary boolForKey:@"include_subdomains"];
    settings.preload = [dictionary boolForKey:@"preload"];
    settings.nosniff = [dictionary boolForKey:@"nosniff"];
    return settings;
}

- (NSDictionary<NSString *, NSNumber *> *) dictionaryValue {
    return @{
             @"enabled": [NSNumber numberWithBool:self.enabled],
             @"max_age": [NSNumber numberWithUnsignedInteger:self.max_age],
             @"include_subdomains": [NSNumber numberWithBool:self.include_subdomains],
             @"preload": [NSNumber numberWithBool:self.preload],
             @"nosniff": [NSNumber numberWithBool:self.nosniff]
             };
}

@end
