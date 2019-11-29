#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CFDomainRegistrationProperties : NSObject

+ (CFDomainRegistrationProperties *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;
- (NSDictionary<NSString *, id> *) dictionaryValue;

// Immutable properties
@property (nonatomic, readonly) BOOL registeredToCloudflare;
@property (strong, nonatomic, readonly) NSString * currentRegistrar;
@property (strong, nonatomic, readonly) NSNumber * renewalPrice;
@property (strong, nonatomic, readonly) NSDate * expiresAt;
@property (strong, nonatomic, readonly) NSDate * registeredAt;
@property (strong, nonatomic, readonly) NSDate * firstRegistered;
@property (nonatomic, readonly) BOOL dnssecEnabled;
@property (strong, nonatomic, readonly) NSDictionary<NSString *, NSString *> * contact;
@property (strong, nonatomic, readonly) NSString * whoisDetails;

// Mutable Properties
@property (strong, nonatomic) NSArray<NSString *> * nameServers;
@property (nonatomic) BOOL autoRenew;
@property (nonatomic) BOOL transferLocked;
@property (nonatomic) BOOL whoisPrivacy;

@end

NS_ASSUME_NONNULL_END
