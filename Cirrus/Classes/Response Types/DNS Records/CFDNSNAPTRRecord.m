#import "CFDNSNAPTRRecord.h"

@implementation CFDNSNAPTRRecord

+ (instancetype) fromDictionary:(NSDictionary<NSString *, id> *) dictionary {
    CFDNSNAPTRRecord * record = [CFDNSNAPTRRecord new];

    record.content = [dictionary stringForKey:@"content"];

    return record;
}

- (NSDictionary<NSString *,id> *) dictionaryValue {
    NSMutableDictionary * base = [super baseDictionary];

    NSDictionary<NSString *, id> * data = [base dictionaryForKey:@"data"];
    NSUInteger order = (NSUInteger)[[data stringForKey:@"order"] integerValue];
    NSUInteger preference = (NSUInteger)[[data stringForKey:@"preference"] integerValue];
    NSString * flags = [data stringForKey:@"flags"];
    NSString * service = [data stringForKey:@"service"];
    NSString * regex = [data stringForKey:@"regex"];
    NSString * replacement = [data stringForKey:@"replacement"];


    NSString * content = format(@"%lu\t%lu\t\"%@\"\t\"%@\"\t\"%@\"\t\"%@\"", (unsigned long)order, (unsigned long)preference, flags, service, regex, replacement);
    [base setValue:content forKey:@"content"];

    return base;
}

@end
