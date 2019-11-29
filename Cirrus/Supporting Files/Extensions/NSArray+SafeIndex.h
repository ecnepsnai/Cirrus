#import <UIKit/UIKit.h>

@interface NSArray (SafeIndex)

/**
 Attempt to locate an object at the given index, when the index may be out of bounds of the array

 @param index The index to check
 @return The object at the given index, or nil if out-of-bounds
 */
- (id _Nullable) objectAtUnsafeIndex:(NSUInteger)index;

@end
