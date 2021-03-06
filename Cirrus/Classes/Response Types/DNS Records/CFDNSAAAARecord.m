#import "CFDNSAAAARecord.h"

@implementation CFDNSAAAARecord

+ (instancetype) fromDictionary:(NSDictionary<NSString *, id> *) dictionary {
    CFDNSAAAARecord * record = [CFDNSAAAARecord new];

    record.content = [dictionary stringForKey:@"content"];

    return record;
}

- (NSDictionary<NSString *,id> *) dictionaryValue {
    NSMutableDictionary * base = [super baseDictionary];

    [base setValue:self.content forKey:@"content"];

    return base;
}

@end
