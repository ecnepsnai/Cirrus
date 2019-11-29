#import <Foundation/Foundation.h>

@interface NSString (Validator)

- (NSError *) validateEmailAddress;
- (NSError *) validateIPv4Address;
- (NSError *) validateIPv6Address;
- (NSError *) validateTTL;
- (NSError *) validateCloudflareAPIKey;
- (NSError *) validateWebURL;
- (NSError *) validASN;

@end
