#import "NSArray+SafeIndex.h"

@implementation NSArray (SafeIndex)

- (id _Nullable) objectAtUnsafeIndex:(NSUInteger)index {
    if (self.count == 0) {
        return nil;
    }

    if ((self.count - 1) < index) {
        return nil;
    } else {
        return [self objectAtIndex:index];
    }
}

@end
