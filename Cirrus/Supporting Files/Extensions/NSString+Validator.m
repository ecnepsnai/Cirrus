#import "NSString+Validator.h"

@implementation NSString (Validator)

/**
 * Validate the given email address
 *
 * @returns A populated NSError object if invalid, nil if valid
 */
- (NSError *) validateEmailAddress {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    if (![emailTest evaluateWithObject:self]) {
        return [NSError errorWithDomain:@""
                                   code:0
                               userInfo:@{NSLocalizedDescriptionKey:
                                              l(@"Invalid email address.")}];
    }
    
    return nil;
}

/**
 * Validate the given IPv4 address
 *
 * @returns A populated NSError object if invalid, nil if valid
 */
- (NSError *) validateIPv4Address {
    NSArray * split = [self componentsSeparatedByString:@"."];
    if (split.count != 4) {
        return [NSError errorWithDomain:@""
                                   code:0
                               userInfo:@{NSLocalizedDescriptionKey:
                                              l(@"Exactly 4 octets must be provided.")}];
    }
    
    for (NSString * octet_string in split) {
        int octet = [octet_string intValue];
        if (octet < 0 || octet > 255) {
            return [NSError errorWithDomain:@""
                                       code:0
                                   userInfo:@{NSLocalizedDescriptionKey:
                                                  l(@"Octets must be in the range of 0 to 255.")}];
        }
    }
    
    int fourth_octet = [[split objectAtIndex:3] intValue];
    if (fourth_octet == 0 || fourth_octet == 255) {
        return [NSError errorWithDomain:@""
                                   code:0
                               userInfo:@{NSLocalizedDescriptionKey:
                                              l(@"Fourth octet cannot be 0 or 255.")}];
    }
    
    return nil;
}

/**
 * Validate the given IPv6 address
 *
 * @returns A populated NSError object if invalid, nil if valid
 */
- (NSError *) validateIPv6Address {
    NSString * address = [self copy];
    NSArray * first_split = [self componentsSeparatedByString:@":"];
    
    // First, expand the address to its full notation
    // (Replace :: with :0000: * missing hextets
    if ([address containsString:@"::"]) {
        if (first_split.count >= 8) {
            return [NSError errorWithDomain:@""
                                       code:0
                                   userInfo:@{NSLocalizedDescriptionKey:
                                                  l(@"No more than 8 hextets can be provided.")}];
        } else {
            unsigned long omitted_octets = 8 - first_split.count;
            NSString * replacement_octets = @":0000";
            for (int i = 0; i < omitted_octets; i ++) {
                replacement_octets = [replacement_octets stringByAppendingString:@":0000"];
            }
            replacement_octets = [replacement_octets stringByAppendingString:@":"];
            
            address = [address stringByReplacingOccurrencesOfString:@"::" withString:replacement_octets];
        }
    }
    
    NSArray * split = [address componentsSeparatedByString:@":"];
    if (split.count > 8) {
        return [NSError errorWithDomain:@""
                                   code:0
                               userInfo:@{NSLocalizedDescriptionKey:
                                              l(@"No more than 8 hextets can be provided.")}];
    } else if (split.count != 8) {
        return [NSError errorWithDomain:@""
                                   code:0
                               userInfo:@{NSLocalizedDescriptionKey:
                                              l(@"Address is too short. Use '::' to omit 0000.")}];
    }
    
    for (NSString * hextet_string in split) {
        NSPredicate *validHex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[0-9A-Fa-f]{0,4}"];
        if ([validHex evaluateWithObject:hextet_string]) {
            
        } else {
            return [NSError errorWithDomain:@""
                                       code:0
                                   userInfo:@{NSLocalizedDescriptionKey:
                                                  l(@"Invalid hexedecimal value.")}];
        }
    }
    
    return nil;
}

/**
 * Validates the given DNS TTL value
 *
 * @returns A populated NSError object if invalid, nil if valid
 */
- (NSError *) validateTTL {
    long long ttl = [self longLongValue];
    if (ttl < 0 || ttl > 2147483647) {
        return [NSError errorWithDomain:@""
                                   code:0
                               userInfo:@{NSLocalizedDescriptionKey:
                                              l(@"TTL must be between 0 and 2147483647.")}];
    }
    
    return nil;
}

- (NSError *) validateCloudflareAPIKey {
    NSString * keyRegex = @"^[a-z0-9]{37}$";
    NSPredicate * keyTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", keyRegex];
    
    if (![keyTest evaluateWithObject:self]) {
        return [NSError errorWithDomain:@""
                                   code:0
                               userInfo:@{NSLocalizedDescriptionKey:
                                              l(@"Invalid Cloudflare API key.")}];
    }
    
    return nil;
}

- (NSError *) validateWebURL {
    if ([self hasPrefix:@"http://"] || [self hasPrefix:@"https://"]) {
        return nil;
    }
    
    return [NSError errorWithDomain:@""
                               code:0
                           userInfo:@{NSLocalizedDescriptionKey:
                                          l(@"URL must start a protocol.")}];
}

- (NSError *) validASN {
    NSString * asnRegex = @"^(AS|)\\d{1,10}$";
    NSPredicate * asnTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", asnRegex];

    if (![asnTest evaluateWithObject:self]) {
        return [NSError errorWithDomain:@""
                                   code:0
                               userInfo:@{NSLocalizedDescriptionKey:
                                              l(@"Invalid ASN.")}];
    }

    return nil;
}

@end
