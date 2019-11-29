#import "CFDomainRegistrationProperties.h"

@interface CFDomainRegistrationProperties ()

@property (nonatomic, readwrite) BOOL registeredToCloudflare;
@property (strong, nonatomic, readwrite) NSString * currentRegistrar;
@property (strong, nonatomic, readwrite) NSNumber * renewalPrice;
@property (strong, nonatomic, readwrite) NSDate * expiresAt;
@property (strong, nonatomic, readwrite) NSDate * registeredAt;
@property (strong, nonatomic, readwrite) NSDate * firstRegistered;
@property (nonatomic, readwrite) BOOL dnssecEnabled;
@property (strong, nonatomic, readwrite) NSDictionary<NSString *, NSString *> * contact;
@property (strong, nonatomic, readwrite) NSString * whoisDetails;

@end

@implementation CFDomainRegistrationProperties

+ (CFDomainRegistrationProperties *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    CFDomainRegistrationProperties * properties = [CFDomainRegistrationProperties new];
    
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    
    properties.registeredToCloudflare = [dictionary boolForKey:@"cloudflare_registration"];
    properties.currentRegistrar = [dictionary stringForKey:@"current_registrar"];
    
    NSDictionary<NSString *, NSNumber *> * priceData = [dictionary dictionaryForKey:@"fees"];
    if (priceData != nil) {
        properties.renewalPrice = [priceData numberForKey:@"registration_fee"];
    }
    
    properties.expiresAt = [dateFormatter dateFromString:[dictionary stringForKey:@"expires_at"]];
    properties.registeredAt = [dateFormatter dateFromString:[dictionary stringForKey:@"registered_at"]];
    properties.firstRegistered = [dateFormatter dateFromString:[dictionary stringForKey:@"created_at"]];
    properties.autoRenew = [dictionary boolForKey:@"auto_renew"];
    properties.dnssecEnabled = [dictionary arrayForKey:@"ds_records"].count > 0;
    properties.contact = [dictionary dictionaryForKey:@"registrant_contact"];
    
    properties.transferLocked = [dictionary boolForKey:@"locked"];
    properties.nameServers = [dictionary arrayForKey:@"name_servers"];
    
    NSDictionary<NSString *, NSNumber *> * whoisData = [dictionary dictionaryForKey:@"whois"];
    if (whoisData != nil) {
        properties.whoisDetails = [whoisData stringForKey:@"raw"];
        properties.whoisPrivacy = [whoisData boolForKey:@"privacy"];
    }
    
    return properties;
}

- (NSDictionary<NSString *, id> *) dictionaryValue {
    return @{
        @"name_servers": self.nameServers,
        @"privacy": [NSNumber numberWithBool:self.whoisPrivacy],
        @"locked": [NSNumber numberWithBool:self.transferLocked],
        @"auto_renew": [NSNumber numberWithBool:self.autoRenew],
    };
}

@end
