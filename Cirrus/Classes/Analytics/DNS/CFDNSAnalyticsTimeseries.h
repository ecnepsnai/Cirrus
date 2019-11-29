#import <Foundation/Foundation.h>

@interface CFDNSAnalyticsTimeseries : NSObject

@property (strong, nonatomic) NSNumber * noerrorCount;
@property (strong, nonatomic) NSNumber * nxdomainCount;

- (void) setCount:(NSNumber *)count forResponseCode:(NSString *)code;

@end
