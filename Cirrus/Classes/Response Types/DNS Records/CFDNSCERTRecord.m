#import "CFDNSCERTRecord.h"

@implementation CFDNSCERTRecord

+ (instancetype) fromDictionary:(NSDictionary<NSString *, id> *) dictionary {
    CFDNSCERTRecord * record = [CFDNSCERTRecord new];

    record.content = [dictionary stringForKey:@"content"];

    return record;
}

- (NSDictionary<NSString *,id> *) dictionaryValue {
    NSMutableDictionary * base = [super baseDictionary];

    NSDictionary<NSString *, id> * data = [base dictionaryForKey:@"data"];
    NSUInteger keyType = (NSUInteger)[[data stringForKey:@"type"] integerValue];
    NSUInteger keyTag = (NSUInteger)[[data stringForKey:@"key_tag"] integerValue];
    NSUInteger keyAlgorithm = (NSUInteger)[[data stringForKey:@"algorithm"] integerValue];
    NSString * certificate = [data stringForKey:@"certificate"];

    [base setValue:format(@"%lu\t%lu\t%lu\t%@", (unsigned long)keyType, (unsigned long)keyTag, (unsigned long)keyAlgorithm, certificate) forKey:@"content"];

    return base;
}

@end
