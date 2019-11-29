#import "CFDNSDSRecord.h"

@implementation CFDNSDSRecord

+ (instancetype) fromDictionary:(NSDictionary<NSString *, id> *) dictionary {
    CFDNSDSRecord * record = [CFDNSDSRecord new];

    record.content = [dictionary stringForKey:@"content"];

    return record;
}

- (NSDictionary<NSString *,id> *) dictionaryValue {
    NSMutableDictionary * base = [super baseDictionary];

    NSDictionary<NSString *, id> * data = [base dictionaryForKey:@"data"];
    NSUInteger tag = (NSUInteger)[[data stringForKey:@"key_tag"] integerValue];
    NSUInteger algorithm = (NSUInteger)[[data stringForKey:@"algorithm"] integerValue];
    NSUInteger digest_type = (NSUInteger)[[data stringForKey:@"digest_type"] integerValue];
    NSString * digest = [data stringForKey:@"digest"];

    [base setValue:format(@"%lu\t%lu\t%lu\t%@", (unsigned long)tag, (unsigned long)algorithm, (unsigned long)digest_type, digest) forKey:@"content"];

    return base;
}

@end
