#import "CFZoneSettings.h"

@implementation CFZoneSettings

+ (CFZoneSettings *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFZoneSettings * settings = [CFZoneSettings new];
    settings.name = dictionary[@"id"];
    
    id value = dictionary[@"value"];
    settings.value = value;

    if (![dictionary[@"modified_on"] isKindOfClass:[NSNull class]]) {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"];
        settings.modified_on = [formatter dateFromString:dictionary[@"modified_on"]];
    }
    
    settings.editable = [dictionary[@"editable"] boolValue];
    return settings;
}

- (NSDictionary<NSString *, id> *) dictionaryValue {
    return @{
        @"id": self.name,
        @"value": self.value
    };
}

@end
