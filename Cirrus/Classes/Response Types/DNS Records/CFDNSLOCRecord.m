#import "CFDNSLOCRecord.h"

@implementation CFDNSLOCRecord

+ (instancetype) fromDictionary:(NSDictionary<NSString *, id> *) dictionary {
    CFDNSLOCRecord * record = [CFDNSLOCRecord new];

    record.content = [dictionary stringForKey:@"content"];

    return record;
}

- (NSDictionary<NSString *,id> *) dictionaryValue {
    NSMutableDictionary * base = [super baseDictionary];

    [base setValue:self.content forKey:@"content"];

    return base;
}

@end
