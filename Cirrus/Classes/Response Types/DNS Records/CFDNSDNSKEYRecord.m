#import "CFDNSDNSKEYRecord.h"

@implementation CFDNSDNSKEYRecord

+ (instancetype) fromDictionary:(NSDictionary<NSString *, id> *) dictionary {
    CFDNSDNSKEYRecord * record = [CFDNSDNSKEYRecord new];

    record.content = [dictionary stringForKey:@"content"];

    return record;
}

- (NSDictionary<NSString *,id> *) dictionaryValue {
    NSMutableDictionary * base = [super baseDictionary];

    NSDictionary<NSString *, id> * data = [base dictionaryForKey:@"data"];
    NSUInteger flags = (NSUInteger)[[data stringForKey:@"flags"] integerValue];
    NSUInteger protocol = (NSUInteger)[[data stringForKey:@"protocol"] integerValue];
    NSUInteger algorithm = (NSUInteger)[[data stringForKey:@"algorithm"] integerValue];
    NSString * publicKey = [data stringForKey:@"public_key"];

    [base setValue:format(@"%lu\t%lu\t%lu\t%@", (unsigned long)flags, (unsigned long)protocol, (unsigned long)algorithm, publicKey) forKey:@"content"];

    return base;
}

@end
