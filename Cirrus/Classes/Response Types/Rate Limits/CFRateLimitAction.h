#import <Foundation/Foundation.h>

@interface CFRateLimitAction : NSObject

typedef NS_ENUM(NSUInteger, CFRateLimitActionMode) {
    CFRateLimitActionModeBan,
    CFRateLimitActionModeSimulate,
};

@property (nonatomic) CFRateLimitActionMode mode;
@property (nonatomic) NSUInteger timeout;
@property (strong, nonatomic) NSDictionary<NSString *, NSString *> * response;

+ (CFRateLimitAction *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;
+ (CFRateLimitAction *) actionWithDefaults;
- (NSDictionary<NSString *, id> *) dictionaryValue;

@end
