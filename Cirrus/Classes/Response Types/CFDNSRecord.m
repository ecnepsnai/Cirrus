#import "CFDNSRecord.h"

@implementation CFDNSRecord

- (NSMutableDictionary<NSString *, id> *) baseDictionary {
    NSMutableDictionary * properties = [NSMutableDictionary new];
#define _dict_add(prop, key) if (prop) { [properties setObject:prop forKey:key]; }
    _dict_add(self.identifier, @"id");
    _dict_add(self.type, @"type")
    _dict_add(self.name, @"name")
    _dict_add(self.content, @"content")
    if (self.proxiable) { [properties setObject:[NSNumber numberWithBool:self.proxiable] forKey:@"proxiable"]; }
    if (self.proxied) { [properties setObject:[NSNumber numberWithBool:self.proxied] forKey:@"proxied"]; }
    if (self.ttl) { [properties setObject:[NSNumber numberWithInt:self.ttl] forKey:@"ttl"]; }
    if (self.priority) { [properties setObject:[NSNumber numberWithInt:self.priority] forKey:@"priority"]; }
    _dict_add(self.zone_id, @"zone_id")
    _dict_add(self.zone_name, @"zone_name")
    _dict_add(self.created_on, @"created_on")
    _dict_add(self.modified_on, @"modified_on")
    _dict_add(self.data, @"data")
    _dict_add(self.meta, @"meta")
    return properties;
}

- (NSDictionary *) dictionaryValue {
    NSAssert(NO, @"Don't invoke dictionaryValue on super CFDNSRecord.");
    return nil;
}

+ (instancetype) fromDictionary:(NSDictionary *)dictionary {
    NSString * type = [dictionary stringForKey:@"type"];
    if (type && [type isKindOfClass:[NSString class]]) {
        if (![SUPPORTED_RECORD_TYPES containsObject:[dictionary stringForKey:@"type"]]) {
            d(@"Unsupported DNS record type: %@", type);
            return nil;
        }
    } else {
        d(@"Unable to determine DNS record type");
        return nil;
    }

    CFDNSRecord * dns;
    if ([type isEqualToString:DNS_RECORD_TYPE_A]) {
        dns = [CFDNSARecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_AAAA]) {
        dns = [CFDNSAAAARecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_CNAME]) {
        dns = [CFDNSCNAMERecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_NS]) {
        dns = [CFDNSNSRecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_CAA]) {
        dns = [CFDNSCAARecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_TXT]) {
        dns = [CFDNSTXTRecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_MX]) {
        dns = [CFDNSMXRecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_SPF]) {
        dns = [CFDNSSPFRecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_LOC]) {
        dns = [CFDNSLOCRecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_SRV]) {
        dns = [CFDNSSRVRecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_PTR]) {
        dns = [CFDNSPTRRecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_CERT]) {
        dns = [CFDNSCERTRecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_DNSKEY]) {
        dns = [CFDNSDNSKEYRecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_DS]) {
        dns = [CFDNSDSRecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_NAPTR]) {
        dns = [CFDNSNAPTRRecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_SMIMEA]) {
        dns = [CFDNSSMIMEARecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_SSHFP]) {
        dns = [CFDNSSSHFPRecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_TLSA]) {
        dns = [CFDNSTLSARecord fromDictionary:dictionary];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_URI]) {
        dns = [CFDNSURIRecord fromDictionary:dictionary];
    }

#define _dns_add(prop, key) if ([dictionary objectForKey:key]) { dns.prop = [dictionary objectForKey:key]; }
    _dns_add(identifier, @"id")
    _dns_add(type, @"type")
    _dns_add(name, @"name")
    _dns_add(zone_id, @"zone_id")
    _dns_add(zone_name, @"zone_name")
    _dns_add(created_on, @"created_on")
    _dns_add(modified_on, @"modified_on")
    _dns_add(data, @"data")
    _dns_add(meta, @"meta")
    if (!dns.content) {
        _dns_add(content, @"content");
    }
    dns.proxied = [dictionary[@"proxied"] boolValue];
    dns.proxiable = [dictionary[@"proxiable"] boolValue];
    dns.ttl = [dictionary[@"ttl"] intValue];
    dns.priority = [dictionary[@"priority"] intValue];
    return dns;
}

+ (instancetype) recordWithType:(NSString *)type {
    CFDNSRecord * dns;

    if ([type isEqualToString:DNS_RECORD_TYPE_A]) {
        dns = [CFDNSARecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_AAAA]) {
        dns = [CFDNSAAAARecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_CNAME]) {
        dns = [CFDNSCNAMERecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_NS]) {
        dns = [CFDNSNSRecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_CAA]) {
        dns = [CFDNSCAARecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_TXT]) {
        dns = [CFDNSTXTRecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_MX]) {
        dns = [CFDNSMXRecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_SPF]) {
        dns = [CFDNSSPFRecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_LOC]) {
        dns = [CFDNSLOCRecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_SRV]) {
        dns = [CFDNSSRVRecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_PTR]) {
        dns = [CFDNSPTRRecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_CERT]) {
        dns = [CFDNSCERTRecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_DNSKEY]) {
        dns = [CFDNSDNSKEYRecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_DS]) {
        dns = [CFDNSDSRecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_NAPTR]) {
        dns = [CFDNSNAPTRRecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_SMIMEA]) {
        dns = [CFDNSSMIMEARecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_SSHFP]) {
        dns = [CFDNSSSHFPRecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_TLSA]) {
        dns = [CFDNSTLSARecord new];
    } else if ([type isEqualToString:DNS_RECORD_TYPE_URI]) {
        dns = [CFDNSURIRecord new];
    }

    dns.type = type;
    dns.proxied = NO;
    dns.ttl = 1;
    return dns;
}

@end
