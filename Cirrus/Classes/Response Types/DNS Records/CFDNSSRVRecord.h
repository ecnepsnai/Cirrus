#import "CFDNSRecord.h"

@interface CFDNSSRVRecord : CFDNSRecord

typedef NS_ENUM(NSUInteger, SRVProtocol) {
    SRVProtocolUnknown = 0,
    SRVProtocolTCP,
    SRVProtocolUDP,
    SRVProtocolTLS,
};
@property (strong, nonatomic) NSString * serviceName;
@property (nonatomic) SRVProtocol protocol;
@property (nonatomic) uint16_t servicePriority;
@property (nonatomic) NSUInteger serviceWeight;
@property (nonatomic) uint16_t port;
@property (strong, nonatomic) NSString * serviceTarget;

@end
