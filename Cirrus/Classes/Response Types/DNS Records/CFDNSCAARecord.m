#import "CFDNSCAARecord.h"

@implementation CFDNSCAARecord

#define TAG_ISSUE @"issue"
#define TAG_WILD @"issuewild"
#define TAG_IODEF @"iodef"

+ (instancetype) fromDictionary:(NSDictionary<NSString *, id> *) dictionary {
    CFDNSCAARecord * record = [CFDNSCAARecord new];

    NSDictionary<NSString *, id> * data = [dictionary dictionaryForKey:@"data"];
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    record.flag = [[data numberForKey:@"flags"] unsignedIntValue];
    record.domain = [data stringForKey:@"value"];
    record.tag = [data stringForKey:@"tag"];

    return record;
}

- (NSString *) recordContent {
    return format(@"0 %@ %@", self.tag, self.domain);
}

- (NSDictionary<NSString *,id> *) dictionaryValue {
    NSMutableDictionary * base = [super baseDictionary];

    [base setValue:[self recordContent] forKey:@"content"];

    return base;
}

@end
