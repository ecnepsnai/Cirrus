#import "CFDNSURIRecord.h"

@implementation CFDNSURIRecord

+ (instancetype) fromDictionary:(NSDictionary<NSString *, id> *) dictionary {
    CFDNSURIRecord * record = [CFDNSURIRecord new];

    record.content = [dictionary stringForKey:@"content"];

    return record;
}

- (NSDictionary<NSString *,id> *) dictionaryValue {
    NSMutableDictionary * base = [super baseDictionary];

    NSDictionary<NSString *, id> * data = [base dictionaryForKey:@"data"];
    NSUInteger weight = (NSUInteger)[[data stringForKey:@"weight"] integerValue];
    NSString * uri_content = [data stringForKey:@"content"];
    uri_content = [uri_content stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];


    NSString * content = format(@"%@\t%lu", uri_content, (unsigned long)weight);
    [base setValue:content forKey:@"content"];

    return base;
}

@end
