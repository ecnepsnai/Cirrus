#import <Foundation/Foundation.h>

@interface NSArray (ObjectAtIndex)

- (NSString * _Nullable) stringAtIndex:(NSUInteger)index;
- (NSNumber * _Nullable) numberAtIndex:(NSUInteger)index;
- (BOOL) boolAtIndex:(NSUInteger)index;
- (NSDictionary * _Nullable) dictionaryAtIndex:(NSUInteger)index;
- (NSArray * _Nullable) arrayAtIndex:(NSUInteger)index;
- (NSUInteger) unsignedIntegerAtIndex:(NSUInteger)index;
- (NSInteger) integerAtIndex:(NSUInteger)index;
- (NSArray * _Nonnull) filteredCopy:(bool (^ _Nonnull)(id _Nonnull object, NSInteger index))filterfn;

@end
