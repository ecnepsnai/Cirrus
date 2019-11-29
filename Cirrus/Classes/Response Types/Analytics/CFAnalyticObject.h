#import <Foundation/Foundation.h>

@interface CFAnalyticObject : NSObject

@property (strong, nonatomic) NSDictionary<NSString *, id> * data;

+ (id) fromDictionary:(NSDictionary<NSString *, id> *)dictionary;

- (NSNumber *) getMin;
- (NSNumber *) getMax;
- (void) setMin:(NSNumber *)newVal;
- (void) setMax:(NSNumber *)newVal;

@end
