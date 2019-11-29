#import <Foundation/Foundation.h>

@interface CFZoneSettings : NSObject

@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) id value;
@property (strong, nonatomic) NSDate * modified_on;
@property (nonatomic) BOOL editable;

+ (CFZoneSettings *) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;
- (NSDictionary<NSString *, id> *) dictionaryValue;

@end
