#import <Foundation/Foundation.h>
#import "CFRateLimitMatch.h"
#import "CFRateLimitAction.h"

@interface CFRateLimit : NSObject <OCSearchDelegate>

@property (strong, nonatomic) NSString * identifier;
@property (nonatomic) BOOL enabled;
@property (strong, nonatomic) NSString * comment;
@property (nonatomic) NSUInteger threshold;
@property (nonatomic) NSUInteger period;
@property (nonatomic) BOOL loginProtect;
@property (strong, nonatomic) CFRateLimitMatch * match;
@property (strong, nonatomic) CFRateLimitAction * action;

+ (CFRateLimit *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;
+ (CFRateLimit *) ruleWithDefaults;
- (NSDictionary<NSString *, id> *) dictionaryValue;
- (NSString *) description;
- (NSString *) ruleDescription;

@end
