#import "CFDNSSSHFPRecord.h"

@implementation CFDNSSSHFPRecord

+ (instancetype) fromDictionary:(NSDictionary<NSString *, id> *) dictionary {
    CFDNSSSHFPRecord * record = [CFDNSSSHFPRecord new];

    record.content = [dictionary stringForKey:@"content"];

    return record;
}

- (NSDictionary<NSString *,id> *) dictionaryValue {
    NSMutableDictionary * base = [super baseDictionary];

    NSDictionary<NSString *, id> * data = [base dictionaryForKey:@"data"];
    NSUInteger type = (NSUInteger)[[data stringForKey:@"type"] integerValue];
    NSUInteger algorithm = (NSUInteger)[[data stringForKey:@"algorithm"] integerValue];
    NSString * fingerprint = [data stringForKey:@"fingerprint"];


    NSString * content = format(@"%lu\t%lu\t%@", (unsigned long)type, (unsigned long)algorithm, fingerprint);
    [base setValue:content forKey:@"content"];

    return base;
}

@end
