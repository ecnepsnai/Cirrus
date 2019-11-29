#import <Foundation/Foundation.h>

@interface NSDictionary (ObjectForKey)

- (NSString * _Nullable) stringForKey:(NSString * _Nonnull)key;
- (NSNumber * _Nullable) numberForKey:(NSString * _Nonnull)key;
- (BOOL) boolForKey:(NSString * _Nonnull)key;
- (NSDictionary * _Nullable) dictionaryForKey:(NSString * _Nonnull)key;
- (NSArray * _Nullable) arrayForKey:(NSString * _Nonnull)key;
- (NSUInteger) unsignedIntegerForKey:(NSString * _Nonnull)key;
- (NSInteger) integerForKey:(NSString * _Nonnull)key;

@end
