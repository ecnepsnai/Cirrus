#import <Foundation/Foundation.h>

@interface CFHSTSSettings : NSObject

@property (nonatomic) BOOL enabled;
@property (nonatomic) NSUInteger max_age;
@property (nonatomic) BOOL include_subdomains;
@property (nonatomic) BOOL preload;
@property (nonatomic) BOOL nosniff;

+ (CFHSTSSettings *) fromDictionary:(NSDictionary<NSString *, NSNumber *> *)dictionary;
- (NSDictionary<NSString *, NSNumber *> *) dictionaryValue;

@end
