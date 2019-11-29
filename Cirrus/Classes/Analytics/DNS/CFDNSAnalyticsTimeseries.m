#import "CFDNSAnalyticsTimeseries.h"

@implementation CFDNSAnalyticsTimeseries

- (void) setCount:(NSNumber *)count forResponseCode:(NSString *)code {
    if ([code isEqualToString:@"NOERROR"]) {
        self.noerrorCount = count;
    } else if ([code isEqualToString:@"NXDOMAIN"]) {
        self.nxdomainCount = count;
    }
}

- (NSString *) description {
    return format(@"NOERROR: %ul. NXERROR: %ul.", [self.noerrorCount unsignedIntValue], [self.nxdomainCount unsignedIntValue]);
}

@end
