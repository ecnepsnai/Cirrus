#import "CFDNSTXTRecord.h"

@implementation CFDNSTXTRecord

+ (instancetype) fromDictionary:(NSDictionary<NSString *, id> *) dictionary {
    CFDNSTXTRecord * record = [CFDNSTXTRecord new];

    record.content = [dictionary stringForKey:@"content"];

    return record;
}

- (NSDictionary<NSString *,id> *) dictionaryValue {
    NSMutableDictionary * base = [super baseDictionary];

    [base setValue:self.content forKey:@"content"];

    return base;
}

@end
