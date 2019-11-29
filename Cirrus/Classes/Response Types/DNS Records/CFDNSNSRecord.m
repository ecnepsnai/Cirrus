#import "CFDNSNSRecord.h"

@implementation CFDNSNSRecord

+ (instancetype) fromDictionary:(NSDictionary<NSString *, id> *) dictionary {
    CFDNSNSRecord * record = [CFDNSNSRecord new];

    record.content = [dictionary stringForKey:@"content"];

    return record;
}

- (NSDictionary<NSString *,id> *) dictionaryValue {
    NSMutableDictionary * base = [super baseDictionary];

    [base setValue:self.content forKey:@"content"];

    return base;
}

@end
