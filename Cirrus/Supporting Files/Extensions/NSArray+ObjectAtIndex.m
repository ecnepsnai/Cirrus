@implementation NSArray (ObjectAtIndex)

- (NSString *) stringAtIndex:(NSUInteger)index {
    return (NSString *)[self objectAtIndex:index];
}

- (NSNumber *) numberAtIndex:(NSUInteger)index {
    return (NSNumber *)[self objectAtIndex:index];
}

- (BOOL) boolAtIndex:(NSUInteger)index {
    return [[self numberAtIndex:index] boolValue];
}

- (NSDictionary *) dictionaryAtIndex:(NSUInteger)index {
    return (NSDictionary *)[self objectAtIndex:index];
}

- (NSArray *) arrayAtIndex:(NSUInteger)index {
    return (NSArray *)[self objectAtIndex:index];
}

- (NSUInteger) unsignedIntegerAtIndex:(NSUInteger)index {
    return [[self numberAtIndex:index] unsignedIntegerValue];
}

- (NSInteger) integerAtIndex:(NSUInteger)index {
    return [[self numberAtIndex:index] integerValue];
}

- (NSArray *) filteredCopy:(bool (^ _Nonnull)(id _Nonnull object, NSInteger index))filterfn {
    NSMutableArray * copy = [NSMutableArray arrayWithArray:self];

    for (NSInteger i = self.count - 1; i >= 0; i--) {
        if (!filterfn(self[i], i)) {
            [copy removeObjectAtIndex:i];
        }
    }

    return [NSArray arrayWithArray:copy];
}

@end
