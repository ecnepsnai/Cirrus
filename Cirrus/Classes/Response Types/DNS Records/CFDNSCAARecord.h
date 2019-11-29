#import "CFDNSRecord.h"

@interface CFDNSCAARecord : CFDNSRecord

@property (nonatomic) uint8_t flag;
@property (strong, nonatomic) NSString * domain;
@property (strong, nonatomic) NSString * tag;

@end
