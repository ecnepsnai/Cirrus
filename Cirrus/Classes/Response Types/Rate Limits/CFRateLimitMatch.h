#import <Foundation/Foundation.h>

@interface CFRateLimitMatchRequest : NSObject

@property (strong, nonatomic) NSArray<NSString *> * methods;
@property (strong, nonatomic) NSArray<NSString *> * schemes;
@property (strong, nonatomic) NSString * url;

+ (CFRateLimitMatchRequest *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;
+ (CFRateLimitMatchRequest *) requesthWithDefaults;
- (NSDictionary<NSString *, id> *) dictionaryValue;

@end

@interface CFRateLimitMatchResponse : NSObject

@property (strong, nonatomic) NSArray<NSNumber *> * status;
@property (nonatomic) BOOL origin_traffic;

+ (CFRateLimitMatchResponse *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;
+ (CFRateLimitMatchResponse *) responseWithDefaults;
- (NSDictionary<NSString *, id> *) dictionaryValue;

@end

@interface CFRateLimitMatch : NSObject

@property (strong, nonatomic) CFRateLimitMatchRequest * request;
@property (strong, nonatomic) CFRateLimitMatchResponse * response;

+ (CFRateLimitMatch *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;
+ (CFRateLimitMatch *) matchWithDefaults;
- (NSDictionary<NSString *, id> *) dictionaryValue;

@end
