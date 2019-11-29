#import "CFDNSSRVRecord.h"

@implementation CFDNSSRVRecord

+ (instancetype) fromDictionary:(NSDictionary<NSString *, id> *) dictionary {
    CFDNSSRVRecord * record = [CFDNSSRVRecord new];

    record.content = [dictionary stringForKey:@"content"];

    NSDictionary<NSString *, id> * meta = [dictionary dictionaryForKey:@"meta"];
    if (!meta || ![meta isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    record.serviceName = [meta stringForKey:@"service"];

    NSString * protocol = [meta stringForKey:@"proto"];
    if (nstrcmp(protocol, @"_tcp")) {
        record.protocol = SRVProtocolTCP;
    } else if (nstrcmp(protocol, @"_udp")) {
        record.protocol = SRVProtocolUDP;
    } else if (nstrcmp(protocol, @"_tls")) {
        record.protocol = SRVProtocolTLS;
    } else {
        record.protocol = SRVProtocolUnknown;
    }

    record.name = [meta stringForKey:@"name"];
    record.servicePriority = [[meta numberForKey:@"priority"] unsignedIntegerValue];
    record.serviceWeight = [[meta numberForKey:@"weight"] unsignedIntegerValue];
    record.port = [[meta numberForKey:@"port"] unsignedIntegerValue];
    record.serviceTarget = [meta stringForKey:@"target"];

    return record;
}

- (NSDictionary<NSString *,id> *) dictionaryValue {
    NSMutableDictionary * base = [super baseDictionary];

    [base setValue:self.content forKey:@"content"];

    NSString * protocol;
    switch (self.protocol) {
        case SRVProtocolTCP:
            protocol = @"_tcp";
            break;
        case SRVProtocolUDP:
            protocol = @"_udp";
            break;
        case SRVProtocolTLS:
            protocol = @"_tls";
            break;
        case SRVProtocolUnknown:
            protocol = @"_ip";
            break;
    }
    [base setValue:format(@"%@.%@.%@", self.serviceName, protocol, self.name) forKey:@"name"];
    [base setValue:format(@"%lu %u %@", (unsigned long)self.serviceWeight, self.port, self.serviceTarget) forKey:@"content"];

    return base;
}

@end
