#import "CFCredentials.h"
#import "NSString+Validator.h"

@implementation CFCredentials

- (BOOL) valid {
    return [self.email validateEmailAddress] == nil && [self.key validateCloudflareAPIKey] == nil;
}

@end
