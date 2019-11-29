#import "CFDNSTLSARecord.h"

@implementation CFDNSTLSARecord

+ (instancetype) fromDictionary:(NSDictionary<NSString *, id> *) dictionary {
    CFDNSTLSARecord * record = [CFDNSTLSARecord new];

    record.content = [dictionary stringForKey:@"content"];

    return record;
}

- (NSDictionary<NSString *,id> *) dictionaryValue {
    NSMutableDictionary * base = [super baseDictionary];

    NSDictionary<NSString *, id> * data = [base dictionaryForKey:@"data"];
    NSUInteger usage = (NSUInteger)[[data stringForKey:@"usage"] integerValue];
    NSUInteger selector = (NSUInteger)[[data stringForKey:@"selector"] integerValue];
    NSUInteger matchingType = (NSUInteger)[[data stringForKey:@"matching_type"] integerValue];
    NSString * certificate = [data stringForKey:@"certificate"];


    NSString * content = format(@"%lu\t%lu\t%lu\t%@", (unsigned long)usage, (unsigned long)selector, (unsigned long)matchingType, certificate);
    [base setValue:content forKey:@"content"];

    return base;
}

@end
